#import "cocos2d.h"

@interface CCSpotLight : CCSprite {

	CCRenderTexture *renderTexture;
	float spotLightRadius;
	ccColor4B renderColor;
}

+(id) initWithRenderTexture:(CCRenderTexture *) texture
			spotLightRadius:(float)radius
				renderColor:(ccColor4B)color;

-(id) initWithRenderTexture:(CCRenderTexture *) texture
			spotLightRadius:(float)radius
				renderColor:(ccColor4B)color;
-(void) tick: (ccTime) dt;
-(void) spreadOutAndRemove;

@property(nonatomic, retain) CCRenderTexture *renderTexture;
@property(nonatomic) float spotLightRadius;
@property(nonatomic) ccColor4B renderColor;

@end
