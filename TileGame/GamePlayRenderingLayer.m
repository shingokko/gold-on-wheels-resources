//
//  HelloWorldLayer.m
//  TileGame
//
//  Created by Shingo Tamura on 5/07/12.
//  Copyright GameCurry 2012. All rights reserved.
//

// Import the interfaces
#import "GamePlayRenderingLayer.h"
#import "GamePlayInputLayer.h"
#import "SimpleAudioEngine.h"
#import "GameOverScene.h"
#import "CCSpotLight.h"
#import "Speedup.h"
#import "Lightup.h"

@interface GamePlayRenderingLayer (PrivateMethods)
-(void)testCollisions:(ccTime)dt;
-(void)win;
-(void)lose;
-(void)addEnemyAtX:(int)x Y:(int)y;
-(BOOL)isProp:(NSString*)prop atTileCoord:(CGPoint)tileCoord forLayer:(CCTMXLayer *)layer;
-(void)preloadAudio;
-(CGPoint)getViewpointPosition:(CGPoint)position;
-(void)pickupPowerups:(CCActor*)subject;
- (void)speedupUsedOnce:(NSNotification *)notification;
- (void)speedupUsedUp:(NSNotification *)notification;
@end

@implementation GamePlayRenderingLayer

@synthesize tileMap = _tileMap;
@synthesize background = _background;
@synthesize player = _player;
@synthesize meta = _meta;
@synthesize foreground = _foreground;
@synthesize melonCount = _melonCount;
@synthesize hud = _hud;
@synthesize mode = _mode;
@synthesize moving = _moving;
@synthesize mask = _mask;
@synthesize spotlight = _spotlight;
@synthesize prevPos = _prevPos;
@synthesize heroSprite;

int maxSight = 400;

- (void) dealloc
{
	self.tileMap = nil;
    self.background = nil;
	self.player = nil;
    self.meta = nil;
    self.foreground = nil;
    self.hud = nil;
	self.mask = nil;
    
	[_tileMap release];
	[_foreground release];
	[_background release];
	[_meta release];
	[_hud release];
	[_enemies release];
	[_projectiles release];	
	[heroSprite release];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

#pragma mark Views & Positions

-(CGPoint)getViewpointPosition:(CGPoint)position {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // We want the player to be always at the centre of the screen so
    // just use the position that's been passed here
    int x = position.x;
    int y = position.y;
    
    CGPoint actualPosition = ccp(x, y);
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    
    return ccpSub(centerOfView, actualPosition);
}

- (CGPoint)tileCoordForPosition:(CGPoint)position {
    int x = position.x / _tileMap.tileSize.width;
    int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - position.y) / _tileMap.tileSize.height;
    return ccp(x, y);
}

-(CGPoint)positionForTileCoord:(CGPoint)tileCoord {
    int x = (tileCoord.x * _tileMap.tileSize.width) + _tileMap.tileSize.width/2;
    int y = (_tileMap.mapSize.height * _tileMap.tileSize.height) - (tileCoord.y * _tileMap.tileSize.height) - _tileMap.tileSize.height/2;
    return ccp(x, y);
}

// Compute a position that fits to the corresponding tile
-(CGPoint) computeTileFittingPosition:(CGPoint)position {
    CGPoint tilePos = [self tileCoordForPosition:position];
    
    CGFloat x = (tilePos.x * _tileMap.tileSize.width) + (_tileMap.tileSize.width / 2.0f);
    CGFloat y = (_tileMap.mapSize.height * _tileMap.tileSize.height) - (tilePos.y * _tileMap.tileSize.height) - (_tileMap.tileSize.height / 2.0f);
    
    CGPoint finalPos = ccp(x, y);
    
    return finalPos;
}

#pragma mark Hero

- (void)testCollisions:(ccTime)dt {
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
        
        if (CGRectContainsPoint(targetRect, _player.position)) {
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

-(void)win {
    GameOverScene *gameOverScene = [GameOverScene node];
    [gameOverScene.layer.label setString:@"You Win!"];
    [[CCDirector sharedDirector] replaceScene:gameOverScene];
}

- (void)lose {
    GameOverScene *gameOverScene = [GameOverScene node];
    [gameOverScene.layer.label setString:@"You Lose!"];
    [[CCDirector sharedDirector] replaceScene:gameOverScene];
}

- (void) playerMoveFinished:(id)sender {
    [self pickupPowerups:_player];
    _moving = NO;
}

-(void)setPlayerPosition:(CGPoint)position facing:(FacingDirection)direction {
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
                //[[SimpleAudioEngine sharedEngine] playEffect:@"hit.caf"];
                return;
            }
            NSString *collection = [properties valueForKey:@"Collectable"];
            if (collection && [collection compare:@"True"] == NSOrderedSame) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"pickup.caf"];
                
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
    
    id actionMove = [CCMoveTo actionWithDuration:0.2f position:position];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(playerMoveFinished:)];
    CGPoint viewPointPosition = [self getViewpointPosition:position];
    id actionViewpointMove = [CCMoveTo actionWithDuration:0.2f position:viewPointPosition];
    id actionMaskMove = [CCMoveTo actionWithDuration:0.2f position:position];
    
    _moving = YES;
    [_player runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    [_mask runAction:[CCSequence actions:actionMaskMove, nil]];
    [self runAction:[CCSequence actions:actionViewpointMove, nil]];
    
    id action = nil;
    
    switch (direction) {
        case kFacingDown:
            if (_player.facingDirection != direction) {
                _player.facingDirection = direction;
                action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_player.frontAnim restoreOriginalFrame:YES]];
            }
            break;
        case kFacingUp:
            if (_player.facingDirection != direction) {
                _player.facingDirection = direction;
                action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_player.backAnim restoreOriginalFrame:YES]];
            }
            break;
        case kFacingLeft:
            if (_player.flipX) {
                _player.flipX = NO;
            }
			
            if (_player.facingDirection != direction) {
                _player.facingDirection = direction;
                action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_player.sideAnim restoreOriginalFrame:YES]];
            }
            break;
			
        default:
            if (!_player.flipX) {
                _player.flipX = YES;
            }
			
            if (_player.facingDirection != direction) {
                _player.facingDirection = direction;
                action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_player.sideAnim restoreOriginalFrame:YES]];
            }
            break;
    }
    
    if (action != nil) {
        [_player runAction:action];
    }
}

- (void) projectileMoveFinished:(id)sender {
    CCSprite *sprite = (CCSprite *)sender;
    [self removeChild:sprite cleanup:YES];
    [_projectiles removeObject:sprite];
}

-(void)throwProjectile:(CGPoint)touchLocation {
    // Create a projectile and put it at the player's location
    CCSprite *projectile = [CCSprite spriteWithFile:@"Projectile.png"];
    projectile.position = _player.position;
    [self addChild:projectile];
    
    // Determine where we wish to shoot the projectile to
    int realX;
    
    // Are we shooting to the left or right?
    CGPoint diff = ccpSub(touchLocation, _player.position);
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

-(void)moveHero:(CGPoint)touchLocation facing:(FacingDirection)direction
{
    CGPoint playerPos = touchLocation;
    
    if (playerPos.x <= (_tileMap.mapSize.width * _tileMap.tileSize.width) &&
        playerPos.y <= (_tileMap.mapSize.height * _tileMap.tileSize.height) &&
        playerPos.y >= 0 &&
        playerPos.x >= 0)
    {
        [self setPlayerPosition:playerPos facing:direction];
    }
}

#pragma mark Powerups

- (void)pickupPowerups:(CCActor*)subject {
    NSMutableArray *powerupsToDelete = [[NSMutableArray alloc] init];
    
    CGRect subjectRect = CGRectMake(
                                       subject.position.x - (subject.contentSize.width/2),
                                       subject.position.y - (subject.contentSize.height/2),
                                       subject.contentSize.width,
                                       subject.contentSize.height);
    
    for (Powerup *target in _powerups) {
        CGRect targetRect = CGRectMake(
                                       target.position.x - (target.contentSize.width/2),
                                       target.position.y - (target.contentSize.height/2),
                                       target.contentSize.width,
                                       target.contentSize.height);
        
        if (CGRectIntersectsRect(subjectRect, targetRect)) {
            [target use:subject];
            [powerupsToDelete addObject:target];
            [[SimpleAudioEngine sharedEngine] playEffect:@"powerup.caf"];
        }
    }
    // remove all the projectiles that hit.
    for (CCSprite *powerup in powerupsToDelete) {
        [_powerups removeObject:powerup];
        [self removeChild:powerup cleanup:YES];
    }
    [powerupsToDelete release];
}

- (void) speedupUsedOnce:(NSNotification *) notification
{
    Powerup* powerup = (Powerup*)notification.object;
    if (powerup.key == @"Lightup") {
        // player's light should be updated now
        _spotlight.spotLightRadius = _player.light;
    }
    else if (powerup.key == @"Speedup") {
        // update moving threshold according to player's current speed
        _hud.movingThreshold = 0.2;
    }
}

- (void) speedupUsedUp:(NSNotification *) notification
{
    CCLOG(@"Speedup used up");
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
		Zombie *zombie = [[Zombie alloc] initWithSpriteFrameName:@"front-1.png"];
		[zombie setCharacterHealth:initialHealth];
		[zombie setPosition:spawnLocation];
		[sceneSpriteBatchNode addChild:zombie z:ZValue];
		[zombie setDelegate:self];
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

#pragma mark Setting Up Scene

-(void) preloadAudio {
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"run.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"pickup.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"powerup.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"hit.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"move.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"broken.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"great.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"selection.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"shoot.caf"];
}

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GamePlayRenderingLayer *renderingLayer = [GamePlayRenderingLayer node];
	
	// add layer as a child to scene
	[scene addChild: renderingLayer];
	
    GamePlayInputLayer *inputLayer = [GamePlayInputLayer node];
    [scene addChild: inputLayer];
    
    renderingLayer.hud = inputLayer;
    
    inputLayer.gameLayer = renderingLayer;
    
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        
        [self preloadAudio];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"adventure.mp3"];
        
        self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMap.tmx"];
        self.background = [_tileMap layerNamed:@"Background"];
		self.foreground = [_tileMap layerNamed:@"Foreground"];
        self.meta = [_tileMap layerNamed:@"Meta"];
        _meta.visible = NO;
		[self addChild:_tileMap z:-1];
		
        // Adding player
        CCTMXObjectGroup *objects = [_tileMap objectGroupNamed:@"Objects"];
        NSAssert(objects != nil, @"'Objects' object group not found");
        
        // by putting the object group into a NSMutableDictionary you get access to a lot of useful properties
        NSMutableDictionary *spawnPoint = [objects objectNamed:@"SpawnPoint"];
        NSAssert(spawnPoint != nil, @"SpawnPoint object not found");
        int x = [[spawnPoint valueForKey:@"x"] intValue];
        int y = [[spawnPoint valueForKey:@"y"] intValue];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"miner.plist"];
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"miner.png"];
        [self addChild:sceneSpriteBatchNode z:0];
        
		self.player = [[CCHero alloc] 
					  initWithSpriteFrame:
					  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"front-1.png"]];
		CGPoint initialPosition = [self computeTileFittingPosition:ccp(x, y)];
        _player.position = ccp(initialPosition.x, initialPosition.y);
		
		NSMutableArray *frontAnimFrames = [NSMutableArray array];
        [frontAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"front-1.png"]];
        [frontAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"front-2.png"]];
        [frontAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"front-1.png"]];
        [frontAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"front-3.png"]];
        
        NSMutableArray *backAnimFrames = [NSMutableArray array];
        [backAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"back-1.png"]];
        [backAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"back-2.png"]];
        [backAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"back-1.png"]];
        [backAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"back-3.png"]];
        
        NSMutableArray *sideAnimFrames = [NSMutableArray array];
        [sideAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"side-1.png"]];
        [sideAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"side-2.png"]];
        [sideAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"side-1.png"]];
        [sideAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"side-3.png"]];
		
		// set up walking animations
        _player.frontAnim = [CCAnimation animationWithFrames:frontAnimFrames delay:0.3f];
        _player.backAnim = [CCAnimation animationWithFrames:backAnimFrames delay:0.3f];
        _player.sideAnim = [CCAnimation animationWithFrames:sideAnimFrames delay:0.3f];
		
        _prevPos = ccp(initialPosition.x, initialPosition.y);
        _player.speed = 20.0f;
        _player.light = 150.0f;
        _hud.movingThreshold = _player.speed;
        _prevPos = CGPointZero;
        _playerAction = nil;
		_mode = 0;
		
        _enemies = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];
		_powerups = [[NSMutableArray alloc] init];
		
        NSMutableDictionary *objectTile;
        for (objectTile in [objects objects]) {
            if ([[objectTile valueForKey:@"Enemy"] intValue] == 1) {
                // no enemy for now
                x = [[objectTile valueForKey:@"x"] intValue];
                y = [[objectTile valueForKey:@"y"] intValue];
                [self addEnemyAtX:x Y:y];
            }
            else {
                int type = [[objectTile valueForKey:@"PowerupType"] intValue];
                Powerup* powerup = nil;
                
                switch (type) {
                    case 1:
                        powerup = [[Speedup alloc] initWithFile:@"boot.png"];
                        break;
                    case 2:
                        powerup = [[Lightup alloc] initWithFile:@"lamp.png"];
                        break;
                    default:
                        break;
                }
                
                if (powerup != nil) {
                    x = [[objectTile valueForKey:@"x"] intValue];
                    y = [[objectTile valueForKey:@"y"] intValue];
                    
                    // Fit object to tile grid
                    CGPoint objTilePos = [self computeTileFittingPosition:ccp(x, y)];
                    powerup.position = ccp(objTilePos.x, objTilePos.y);
                    [self addChild:powerup];
                    [_powerups addObject:powerup];
                }
            }
        }

		// Spotlight
		_mask = [CCRenderTexture renderTextureWithWidth:512 height:352]; // screen size + tile size
		_mask.position = _player.position;
		[[_mask sprite] setBlendFunc: (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA }];
		[self addChild:_mask z:1];
		_spotlight = [CCSpotLight initWithRenderTexture:_mask spotLightRadius:_player.light renderColor:ccc4(0, 0, 0, 255)];
		[self addChild:_spotlight z:2 tag:999];
		
        [sceneSpriteBatchNode addChild:_player z:kHeroSpriteZValue tag:kHeroSpriteTagValue];
        self.position = [self getViewpointPosition:_player.position];
        
		//Observer notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speedupUsedOnce:) name:@"usedOnce" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speedupUsedUp:) name:@"usedUp" object:nil];
    
		//Schedule updates
		[self schedule:@selector(testCollisions:)];
		[self scheduleUpdate];
	}
	return self;
}

-(void)update:(ccTime)deltaTime
{
	CCArray *listOfGameObjects =  [sceneSpriteBatchNode children];
    for (GameCharacter *tempChar in listOfGameObjects) {
        [tempChar updateStateWithDeltaTime:deltaTime andListOfGameObjects:listOfGameObjects];                         // 3
    }
}


@end
