//
//  HelloWorldLayer.m
//  TileGame
//
//  Created by Shingo Tamura on 5/07/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"
#import "GameOverScene.h"
#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedJoystickExample.h"
#import "SneakyJoystickSkinnedDPadExample.h"
#import "SneakyButton.h"
#import "SneakyButtonSkinnedBase.h"
#import "ColoredCircleSprite.h"

#import "Hero.h"
#import "Zombie.h"

@implementation HelloWorldHud

@synthesize gameLayer = _gameLayer;

-(CGPoint) applyVelocity: (CGPoint)velocity position:(CGPoint)position delta:(ccTime)delta {
	return CGPointMake(position.x + velocity.x * delta, position.y + velocity.y * delta);
}

-(void)applyDirectionalJoystick:(SneakyJoystick*)joystick toNode:(CCNode*)node forTimeDelta:(ccTime)delta
{
	// you can create a velocity specific to the node if you wanted, just supply a different multiplier
	// which will allow you to do a parallax scrolling of sorts
	//CGPoint scaledVelocity = ccpMult(joystick.velocity, 240.0f);
    
    if (joystick.isActive) {
        // apply the scaled velocity to the position over delta
        //[_gameLayer moveHero:node.position];
        //node.position = [self applyVelocity:scaledVelocity position:node.position delta:delta];
        
        _tmpMovingDelta += delta;
        
        if (_tmpMovingDelta >= _movingThreshold) {
            CGPoint newPosition = ccp(node.position.x, node.position.y);
            newPosition.x += joystick.stickPosition.x;
            newPosition.y += joystick.stickPosition.y;
            
            _tmpMovingDelta = 0.0f;
            [_gameLayer moveHero:newPosition];
        }
    }
}
-(void)applyAttackingJoystick:(SneakyJoystick*)joystick toNode:(CCNode*)node forTimeDelta:(ccTime)delta
{
	// you can create a velocity specific to the node if you wanted, just supply a different multiplier
	// which will allow you to do a parallax scrolling of sorts
	//CGPoint scaledVelocity = ccpMult(joystick.velocity, 240.0f);
    
    if (joystick.isActive) {
        
        _tmpAttackingDelta += delta;
        
        if (_tmpAttackingDelta >= _attackingThreshold) {
            CGPoint newPosition = ccp(node.position.x, node.position.y);
            newPosition.x += joystick.stickPosition.x;
            newPosition.y += joystick.stickPosition.y;
            
            _tmpAttackingDelta = 0.0f;
            [_gameLayer throwProjectile:newPosition];
        }
    }
}

-(void)update:(ccTime)deltaTime {
    // need to add [glView setMultipleTouchEnabled:YES]; to AppDelegate.m to enable multi-touch
    [self applyDirectionalJoystick:leftJoystick toNode:_gameLayer.heroSprite forTimeDelta:deltaTime];
    [self applyAttackingJoystick:rightJoystick toNode:_gameLayer.heroSprite forTimeDelta:deltaTime];
}

-(void) onEnter
{
    CCLOG(@"HelloWorldHud onEnter.");
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:2 swallowsTouches:YES];
    [super onEnter];
}

-(void) onExit
{
    CCLOG(@"HelloWorldHud onExit.");
    [[CCTouchDispatcher sharedDispatcher] removeDelegate: self];
    [super onExit];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CCLOG(@"HelloWorldHud touched.");
	return NO;
}

-(void)initJoystickAndButtons {
    // initialize a joystick
    SneakyJoystickSkinnedBase *leftJoy = [[[SneakyJoystickSkinnedBase alloc] init] autorelease];
    leftJoy.position = ccp(64, 64);
    leftJoy.backgroundSprite = [ColoredCircleSprite circleWithColor:ccc4(255, 0, 0, 128) radius:64];
    leftJoy.thumbSprite = [ColoredCircleSprite circleWithColor:ccc4(0, 0, 255, 200) radius:32];
    leftJoy.joystick = [[SneakyJoystick alloc] initWithRect:CGRectMake(0,0,128,128)];
    leftJoystick = [leftJoy.joystick retain];
    
    [self addChild:leftJoy z:2];
    
    // initialize a joystick
    SneakyJoystickSkinnedBase *rightJoy = [[[SneakyJoystickSkinnedBase alloc] init] autorelease];
    rightJoy.position = ccp(416, 64);
    rightJoy.backgroundSprite = [ColoredCircleSprite circleWithColor:ccc4(255, 0, 0, 128) radius:64];
    rightJoy.thumbSprite = [ColoredCircleSprite circleWithColor:ccc4(0, 0, 255, 200) radius:32];
    rightJoy.joystick = [[SneakyJoystick alloc] initWithRect:CGRectMake(0,0,128,128)];
    rightJoystick = [rightJoy.joystick retain];
    
    [self addChild:rightJoy z:2];
}

-(id) init
{
    if ((self = [super init])) {
        
        self.isTouchEnabled = YES;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        _label = [CCLabelTTF labelWithString:@"0" dimensions:CGSizeMake(50, 20)
                               alignment:UITextAlignmentRight fontName:@"Verdana-Bold" 
                                fontSize:18.0];
        
        _label.color = ccc3(0,0,0);
        int margin = 10;
        _label.position = ccp((winSize.width/2) - (_label.contentSize.width/2)
                             - margin, _label.contentSize.height/2 + margin);
        
        [self addChild:_label];
        
        [self initJoystickAndButtons];
        [self scheduleUpdate];
        
        _tmpAttackingDelta = 0.0f;
        _tmpMovingDelta = 0.0f;
        
        _movingThreshold = 0.3f;
        _attackingThreshold = 0.8f;
    }
    return self;
}

- (void)melonCountChanged:(int)melonCount {
    [_label setString:[NSString stringWithFormat:@"%d", melonCount]];
}

@end

@interface HelloWorldLayer (PrivateMethods)
-(void)testCollisions:(ccTime)dt;
-(void)win;
-(void)lose;
-(void)addEnemyAtX:(int)x Y:(int)y;
-(BOOL)isProp:(NSString*)prop atTileCoord:(CGPoint)tileCoord forLayer:(CCTMXLayer *)layer;
@end

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Right after the implementation section
@synthesize tileMap = _tileMap;
@synthesize background = _background;
@synthesize meta = _meta;
@synthesize foreground = _foreground;
@synthesize melonCount = _melonCount;
@synthesize hud = _hud;
@synthesize mode = _mode;
@synthesize moving = _moving;
@synthesize vector = _vector;
@synthesize destination = _destination;

@synthesize heroSprite;

int maxSight = 400;

- (void) dealloc
{
	self.tileMap = nil;
    self.background = nil;
    self.meta = nil;
    self.foreground = nil;
    self.hud = nil;
    
	[_tileMap release];
	[_foreground release];
	[_background release];
	[_meta release];
	[_hud release];
	[_enemies release];
	[_projectiles release];
	
	[heroSprite release];
	
	[super dealloc];
}

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
    HelloWorldHud *hud = [HelloWorldHud node];
    [scene addChild: hud];
    
    layer.hud = hud;
    
    hud.gameLayer = layer;
    
	// return the scene
	return scene;
}

-(void)setViewpointCenter:(CGPoint) position animate:(BOOL)animate {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    int x = MAX(position.x, winSize.width / 2);
    int y = MAX(position.y, winSize.height / 2);
    
    x = MIN(x, (_tileMap.mapSize.width * _tileMap.tileSize.width) - winSize.width / 2);
    y = MIN(y, (_tileMap.mapSize.height * _tileMap.tileSize.height) - winSize.height/2);
    
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    
    if (animate) {
        id actionMove = [CCMoveTo actionWithDuration:0.2 position:viewPoint];
        [self runAction:[CCSequence actions:actionMove, nil]];
    }
    else {
        self.position = viewPoint;
    }
}

-(CGPoint)tileCoordForPosition:(CGPoint)position {
    int x = position.x / _tileMap.tileSize.width;
    int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - position.y) / _tileMap.tileSize.height;
    return ccp(x, y);
}

-(CGPoint)positionForTileCoord:(CGPoint)tileCoord {
    int x = (tileCoord.x * _tileMap.tileSize.width) + _tileMap.tileSize.width/2;
    int y = (_tileMap.mapSize.height * _tileMap.tileSize.height) - (tileCoord.y * _tileMap.tileSize.height) - _tileMap.tileSize.height/2;
    return ccp(x, y);
}

-(void)testCollisions:(ccTime)dt {
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    
    // iterate through projectiles
    for (CCSprite *projectile in _projectiles) {
        CGRect projectileRect = CGRectMake(
                                           projectile.position.x - (projectile.contentSize.width/2),
                                           projectile.position.y - (projectile.contentSize.height/2),
                                           projectile.contentSize.width,
                                           projectile.contentSize.height);
        
        NSMutableArray *targetsToDelete = [[NSMutableArray alloc] init];
        
        // iterate through enemies, see if any intersect with current projectile
        for (CCSprite *target in _enemies) {
            CGRect targetRect = CGRectMake(
                                           target.position.x - (target.contentSize.width/2),
                                           target.position.y - (target.contentSize.height/2),
                                           target.contentSize.width,
                                           target.contentSize.height);
            
            if (CGRectIntersectsRect(projectileRect, targetRect)) {
                [targetsToDelete addObject:target];
                [[SimpleAudioEngine sharedEngine] playEffect:@"broken.caf"];
            }
        }
        
        // delete all hit enemies
        for (CCSprite *target in targetsToDelete) {
            [_enemies removeObject:target];
            [self removeChild:target cleanup:YES];
        }
        
        if (targetsToDelete.count > 0) {
            // add the projectile to the list of ones to remove
            [projectilesToDelete addObject:projectile];
        }
        [targetsToDelete release];
    }
    
    // detect player colliding with an enemy
    for (CCSprite *target in _enemies) {
        CGRect targetRect = CGRectMake(target.position.x - (target.contentSize.width/2), target.position.y - (target.contentSize.height/2), target.contentSize.width, target.contentSize.height);
        
        if (CGRectContainsPoint(targetRect, heroSprite.position)) {
            [self lose];
        }
    }
    // remove all the projectiles that hit.
    for (CCSprite *projectile in projectilesToDelete) {
        [_projectiles removeObject:projectile];
        [self removeChild:projectile cleanup:YES];
    }
    [projectilesToDelete release];
}

-(void)lose {
    GameOverScene *gameOverScene = [GameOverScene node];
    [gameOverScene.layer.label setString:@"You Lose!"];
    [[CCDirector sharedDirector] replaceScene:gameOverScene];
}

-(void)win {
    GameOverScene *gameOverScene = [GameOverScene node];
    [gameOverScene.layer.label setString:@"You Win!"];
    [[CCDirector sharedDirector] replaceScene:gameOverScene];
}

-(void)playerMoveFinished:(id)sender {
    [[SimpleAudioEngine sharedEngine] playEffect:@"step.caf"];
    _moving = NO;
}

-(void)setPlayerPosition:(CGPoint)position {
    
    if (_moving) {
        return;
    }
    
    CGPoint tileCoord = [self tileCoordForPosition:position];
    int metaGid = [_meta tileGIDAt:tileCoord];
    
    if (metaGid) {
        NSDictionary *properties = [_tileMap propertiesForGID:metaGid];
        if (properties) {
            NSString *collision = [properties valueForKey:@"Collidable"];
            if (collision && [collision compare:@"True"] == NSOrderedSame) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"hit.caf"];
                return;
            }
            NSString *collection = [properties valueForKey:@"Collectable"];
            if (collection && [collection compare:@"True"] == NSOrderedSame) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"great.caf"];
                
                [_meta removeTileAt:tileCoord];
                [_foreground removeTileAt:tileCoord];
                
                self.melonCount++;
                [_hud melonCountChanged:_melonCount];
                
                // TODO turn it into a const
                if (_melonCount == 11) {
                    [self win];
                }
            }
        }
    }
    
    id actionMove = [CCMoveTo actionWithDuration:0.2 position:position];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self
                                             selector:@selector(playerMoveFinished:)];
    
    _moving = YES;
    [heroSprite runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    
    [self setViewpointCenter:heroSprite.position animate:YES];
    
}

-(void)projectileMoveFinished:(id)sender {
    CCSprite *sprite = (CCSprite *)sender;
    [self removeChild:sprite cleanup:YES];
    [_projectiles removeObject:sprite];
}

-(void)throwProjectile:(CGPoint)touchLocation {
    // Create a projectile and put it at the player's location
    CCSprite *projectile = [CCSprite spriteWithFile:@"Projectile.png"];
    projectile.position = heroSprite.position;
    [self addChild:projectile];
    
    // Determine where we wish to shoot the projectile to
    int realX;
    
    // Are we shooting to the left or right?
    CGPoint diff = ccpSub(touchLocation, heroSprite.position);
    if (diff.x > 0)
    {
        realX = (_tileMap.mapSize.width * _tileMap.tileSize.width) + (projectile.contentSize.width/2);
    }
    else {
        realX = -(_tileMap.mapSize.width * _tileMap.tileSize.width) - (projectile.contentSize.width/2);
    }
    
    float ratio = (float) diff.y / (float) diff.x;
    int realY = ((realX - projectile.position.x) * ratio) + projectile.position.y;
    CGPoint realDest = ccp(realX, realY);
    
    // Determine the length of how far we're shooting
    int offRealX = realX - projectile.position.x;
    int offRealY = realY - projectile.position.y;
    float length = sqrtf((offRealX*offRealX) + (offRealY*offRealY));
    float velocity = 480/1; // 480pixels/1sec
    float realMoveDuration = length/velocity;
    
    // Move projectile to actual endpoint
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector (projectileMoveFinished:)];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"shoot.caf"];
    
    [projectile runAction:
     [CCSequence actionOne:[CCMoveTo actionWithDuration: realMoveDuration position: realDest] two: actionMoveDone]];
    
    [_projectiles addObject:projectile];
}

-(void)moveHero:(CGPoint)touchLocation
{
    CGPoint playerPos = heroSprite.position;
    CGPoint diff = ccpSub(touchLocation, playerPos);
    if (abs(diff.x) > abs(diff.y)) {
        if (diff.x > 0) {
            playerPos.x += _tileMap.tileSize.width;
        } else {
            playerPos.x -= _tileMap.tileSize.width;
        }
    } else {
        if (diff.y > 0) {
            playerPos.y += _tileMap.tileSize.height;
        } else {
            playerPos.y -= _tileMap.tileSize.height;
        }
    }
    
    if (playerPos.x <= (_tileMap.mapSize.width * _tileMap.tileSize.width) &&
        playerPos.y <= (_tileMap.mapSize.height * _tileMap.tileSize.height) &&
        playerPos.y >= 0 &&
        playerPos.x >= 0)
    {
        [self setPlayerPosition:playerPos];
    }
}

#pragma mark PathFinding

-(BOOL)isValidTileCoord:(CGPoint)tileCoord {
    if (tileCoord.x < 0 || tileCoord.y < 0 || 
        tileCoord.x >= _tileMap.mapSize.width ||
        tileCoord.y >= _tileMap.mapSize.height) {
        return FALSE;
    } else {
        return TRUE;
    }
}

-(BOOL)isProp:(NSString*)prop atTileCoord:(CGPoint)tileCoord forLayer:(CCTMXLayer *)layer {
    if (![self isValidTileCoord:tileCoord]) return NO;
    int gid = [layer tileGIDAt:tileCoord];
    NSDictionary * properties = [_tileMap propertiesForGID:gid];
    if (properties == nil) return NO;    
    return [properties objectForKey:prop] != nil;
}

-(BOOL)isWallAtTileCoord:(CGPoint)tileCoord {
    return [self isProp:@"Collidable" atTileCoord:tileCoord forLayer:_meta];
}

-(NSArray *)walkableAdjacentTilesCoordForTileCoord:(CGPoint)tileCoord
{
	NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:8];
    
    BOOL t = NO;
    BOOL l = NO;
    BOOL b = NO;
    BOOL r = NO;
	
	// Top
	CGPoint p = CGPointMake(tileCoord.x, tileCoord.y - 1);
	if ([self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
        t = YES;
	}
	
	// Left
	p = CGPointMake(tileCoord.x - 1, tileCoord.y);
	if ([self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
        l = YES;
	}
	
	// Bottom
	p = CGPointMake(tileCoord.x, tileCoord.y + 1);
	if ([self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
        b = YES;
	}
	
	// Right
	p = CGPointMake(tileCoord.x + 1, tileCoord.y);
	if ([self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
        r = YES;
	}
    
    
	// Top Left
	p = CGPointMake(tileCoord.x - 1, tileCoord.y - 1);
	if (t && l && [self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
	
	// Bottom Left
	p = CGPointMake(tileCoord.x - 1, tileCoord.y + 1);
	if (b && l && [self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
	
	// Top Right
	p = CGPointMake(tileCoord.x + 1, tileCoord.y - 1);
	if (t && r && [self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
	
	// Bottom Right
	p = CGPointMake(tileCoord.x + 1, tileCoord.y + 1);
	if (b && r && [self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}

	return [NSArray arrayWithArray:tmp];
}

#pragma mark Zombie Outbreak

-(void)createObjectOfType:(GameObjectType)objectType 
               withHealth:(int)initialHealth
               atLocation:(CGPoint)spawnLocation 
               withZValue:(int)ZValue {
    
    if (kEnemyTypeZombie == objectType) {
		CCLOG(@"Creating Zombie");
		Zombie *zombie = [[Zombie alloc] initWithSpriteFrameName:@"dog_forward_1.png"];
		[zombie setCharacterHealth:initialHealth];
		[zombie setPosition:spawnLocation];
		[sceneSpriteBatchNode addChild:zombie z:ZValue];
		[zombie setDelegate:self];
#if (ENEMY_STATE_DEBUG != 0)
        CCLabelBMFont *debugLabel = [CCLabelBMFont labelWithString:@"NoneNone" fntFile:@"SpaceVikingFont.fnt"];
        [self addChild:debugLabel];
        [zombie setMyDebugLabel:debugLabel];
#endif
        [zombie release];
    }
}

-(void)addEnemyAtX:(int)x Y:(int)y
{	
	CCLOG(@"Creating Zombie");
	[self createObjectOfType:kEnemyTypeZombie withHealth:100 
				  atLocation:ccp(x, y) 
				  withZValue:2];
}

-(void)update:(ccTime)deltaTime
{
	CCArray *listOfGameObjects =  [sceneSpriteBatchNode children];
    for (GameCharacter *tempChar in listOfGameObjects) {
        [tempChar updateStateWithDeltaTime:deltaTime andListOfGameObjects:listOfGameObjects];                         // 3
    }
}

#pragma mark Events

-(id)init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"pickup.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"hit.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"move.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"broken.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"great.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"selection.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"shoot.caf"];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"adventure.mp3"];
        
        // CCTMXTiledMap is a CCNode which means you can set its position, scale, etc.
        self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMap.tmx"];
        self.background = [_tileMap layerNamed:@"Background"]; // Name of the layer
        
        // Adding player
        CCTMXObjectGroup *objects = [_tileMap objectGroupNamed:@"Objects"];
        NSAssert(objects != nil, @"'Objects' object group not found");
        
        // by putting the object group into a NSMutableDictionary you get access to a lot of useful properties
        NSMutableDictionary *spawnPoint = [objects objectNamed:@"SpawnPoint"];
        NSAssert(spawnPoint != nil, @"SpawnPoint object not found");
        int x = [[spawnPoint valueForKey:@"x"] intValue];
        int y = [[spawnPoint valueForKey:@"y"] intValue];
	
		//self.player = [CCSprite spriteWithFile:@"Player.png"];
        //player.position = ccp(x, y);
        
        _projectiles = [[NSMutableArray alloc] init];
        [self schedule:@selector(testCollisions:)];

        _mode = 0;
        
        self.meta = [_tileMap layerNamed:@"Meta"];
        _meta.visible = NO;
        
        self.foreground = [_tileMap layerNamed:@"Foreground"];
        
        //[self addChild:player z:1];
        //[self setViewpointCenter:player.position animate:NO]; // set the viewpoint to the players position
        [self addChild:_tileMap z:-1];
		
		//Use sprite batch node for efficient sprite rendering
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"CatMaze.plist"];
		sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"CatMaze.png"];
		[self addChild:sceneSpriteBatchNode z:0];
		
		//Create hero
		heroSprite = [[Hero alloc] 
					  initWithSpriteFrame:
					  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"cat_forward_1.png"]];
		heroSprite.position = ccp(x, y);
		[sceneSpriteBatchNode addChild:heroSprite z:kHeroSpriteZValue tag:kHeroSpriteTagValue];
		
		[self setViewpointCenter:heroSprite.position animate:NO]; 
		
		[self scheduleUpdate];
		
		//Add zombies
		for (spawnPoint in [objects objects]) {
			if ([[spawnPoint valueForKey:@"Enemy"] intValue] == 1){
				x = [[spawnPoint valueForKey:@"x"] intValue];
				y = [[spawnPoint valueForKey:@"y"] intValue];
				[self addEnemyAtX:x Y:y];
			}
		}
    }
	return self;
}

@end
