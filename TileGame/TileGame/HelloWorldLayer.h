//
//  HelloWorldLayer.h
//  TileGame
//
//  Created by Shingo Tamura on 5/07/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "CommonProtocol.h"
#import "GameCharacter.h"

@class HelloWorldLayer;
@class SneakyJoystick;
@class SneakyButton;

@interface HelloWorldHud : CCLayer
{
    CCLabelTTF *_label;
    HelloWorldLayer *_gameLayer;
	SneakyJoystick *leftJoystick;
	SneakyJoystick *rightJoystick;
    ccTime _tmpMovingDelta;
    ccTime _tmpAttackingDelta;
    ccTime _movingThreshold;
    ccTime _attackingThreshold;
}

-(void)melonCountChanged:(int)melonCount;

@property (nonatomic, assign) HelloWorldLayer *gameLayer;

@end

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GameplayLayerDelegate>
{
    CCTMXTiledMap *_tileMap;
    CCTMXLayer *_foreground;
    CCTMXLayer *_background;
    //CCSprite *player;
    CCTMXLayer *_meta;
    int _mode;
    int _melonCount;
    HelloWorldHud *_hud;
    bool _moving;
    CGPoint _vector;
    CGPoint _destination;    
    NSMutableArray *_enemies;
    NSMutableArray *_projectiles;
	
	GameCharacter *heroSprite;
	CCSpriteBatchNode *sceneSpriteBatchNode;
}

@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (nonatomic, retain) CCTMXLayer *background;
//@property (nonatomic, retain) GameSprite *player;
@property (nonatomic, retain) CCTMXLayer *meta;
@property (nonatomic, retain) CCTMXLayer *foreground;
@property (nonatomic, assign) int melonCount;
@property (nonatomic, retain) HelloWorldHud *hud;
@property (nonatomic, assign) int mode;
@property (nonatomic, assign) bool moving;
@property (nonatomic, assign) CGPoint destination;
@property (nonatomic, assign) CGPoint vector;

@property (nonatomic, retain) GameCharacter *heroSprite;

+(CCScene *) scene;
-(void)moveHero:(CGPoint)touchPosition;
-(void)throwProjectile:(CGPoint)touchLocation;
- (CGPoint)tileCoordForPosition:(CGPoint)position;
- (CGPoint)positionForTileCoord:(CGPoint)tileCoord;
-(void)setPlayerPosition:(CGPoint)position;
-(void)projectileMoveFinished:(id)sender;
-(void)playerMoveFinished:(id)sender;


- (NSArray *)walkableAdjacentTilesCoordForTileCoord:(CGPoint)tileCoord;
-(BOOL)isWallAtTileCoord:(CGPoint)tileCoord;
-(BOOL)isValidTileCoord:(CGPoint)tileCoord;

@end
