#import "CCSpotLight.h"

@implementation CCSpotLight

@synthesize renderTexture;
@synthesize spotLightRadius;
@synthesize renderColor;

+(id) initWithRenderTexture:(CCRenderTexture *) texture
			spotLightRadius:(float)radius
				renderColor:(ccColor4B)color
{
	return [[[self alloc] initWithRenderTexture:texture
								spotLightRadius:radius
									renderColor:color] autorelease];
}

-(id) initWithRenderTexture:(CCRenderTexture *) texture
			spotLightRadius:(float)radius
				renderColor:(ccColor4B)color
{
	if( (self = [super init] )) {
		
		self.position = ccp(240, 160);
		self.renderTexture = texture;
		self.spotLightRadius = radius;
		self.renderColor = color;
		[self schedule: @selector(tick:)];
	}
	return self;
}

-(void) tick: (ccTime) dt 
{	
	int segs = 45;
	GLfloat *vertices = malloc( sizeof(GLfloat)*2*(segs));
	GLfloat *coordinates = malloc( sizeof(GLfloat)*2*(segs));
	ccColor4B *colors = malloc( sizeof(ccColor4B)*(segs));
	
	memset(vertices,0, sizeof(GLfloat)*2*(segs));
	memset(coordinates,0, sizeof(GLfloat)*2*(segs));
	
    [renderTexture clear:renderColor.r 
					   g:renderColor.g
					   b:renderColor.b
					   a:renderColor.a];
	
	colors[0] = ccc4(0, 0, 0, 255);
	for (int i = 1; i < segs; i++)
	{
		colors[i] = ccc4(0, 0, 0, 0);
	}
	
	const float coef = 2.0f * (float)M_PI/(segs-2) ;
	
	vertices[0] = self.position.x;
	vertices[1] = self.position.y;
	coordinates[0] = self.position.x;
	coordinates[1] = (contentSize_.height-self.position.y);
	for(int i=1;i<=segs;i++)
	{
		float rads = i*coef;
		float j = self.spotLightRadius * cosf(rads) + self.position.x;
		float k = self.spotLightRadius * sinf(rads) + self.position.y;
		
		vertices[i*2] = j;
		vertices[i*2+1] = k;
		
		coordinates[i*2] = (j);
		coordinates[i*2+1] = (contentSize_.height-k);
	}
	
    // Update the render texture
    [self.renderTexture begin];
	
    glBindTexture(GL_TEXTURE_2D, (GLuint)self.renderTexture);
	glBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_ALPHA);
	glColorMask(0.0f, 0.0f, 0.0f, 1.0f);
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
	
	glDrawArrays(GL_TRIANGLE_FAN, 0, segs);
	
	glColorMask(1.0f, 1.0f, 1.0f, 1.0f);
	glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	
    [self.renderTexture end];
	
	free(vertices);
	free(coordinates);
	free(colors);
}

-(void) spreadOutAndRemove
{
	[self schedule: @selector(spreadOutTimer)];
}

-(void) spreadOutTimer
{
	self.spotLightRadius += 3;
	
	if(self.spotLightRadius > 300)
	{
		[self unschedule:@selector(spread)];
		[self unschedule:@selector(tick:)];
		[renderTexture removeFromParentAndCleanup:YES];
		[self removeFromParentAndCleanup:YES];
	}
}

@end
