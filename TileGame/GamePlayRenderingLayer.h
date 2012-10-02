//
//  HelloWorldLayer.h
//  TileGame
//
//  Created by Shingo Tamura on 5/07/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "CCHero.h"
#import "CommonProtocol.h"
#import "Zombie.h"

@class GamePlayInputLayer;
@class CCSpotLight;
@class Speedup;

@interface GamePlayRenderingLayer : CCLayer <GameplayLayerDelegate>
{
    CCTMXTiledMap *_tileMap;
    CCTMXLayer *_foreground;
    CCTMXLayer *_background;
    CCTMXLayer *_meta;
	
	GamePlayInputLayer *_hud;
	int _melonCount;
	
    CCRenderTexture *_mask;
    CCSpotLight *_spotlight;
	
    int _mode;
	bool _moving;
    CGPoint _prevPos;
    id _playerAction;
    
	CCHero *_player;
    NSMutableArray *_enemies;
    NSMutableArray *_projectiles;
    NSMutableArray *_powerups;
	
	CCSpriteBatchNode *sceneSpriteBatchNode;
	CCSpriteBatchNode *zombieSpriteBatchNode;
    
    ccTime _tmpPathFindingDelta;
    ccTime _pathFindingThreshold;
}

@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (nonatomic, retain) CCTMXLayer *background;
@property (nonatomic, retain) CCHero *player;
@property (nonatomic, retain) CCTMXLayer *meta;
@property (nonatomic, retain) CCTMXLayer *foreground;
@property (nonatomic, retain) CCRenderTexture *mask;
@property (nonatomic, retain) CCSpotLight *spotlight;

@property (nonatomic, assign) int melonCount;
@property (nonatomic, retain) GamePlayInputLayer *hud;

@property (nonatomic, assign) int mode;
@property (nonatomic, assign) bool moving;
@property (nonatomic, assign) CGPoint prevPos;
@property (nonatomic, retain) GameCharacter *heroSprite;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(void)moveHero:(CGPoint)touchPosition facing:(FacingDirection)direction;
-(void)throwProjectile:(CGPoint)touchLocation;

-(CGPoint)tileCoordForPosition:(CGPoint)position;
-(CGPoint)positionForTileCoord:(CGPoint)tileCoord;
-(CGPoint) computeTileFittingPosition:(CGPoint)position;
-(void)setPlayerPosition:(CGPoint)position facing:(FacingDirection)direction;
-(void)projectileMoveFinished:(id)sender;
-(void)playerMoveFinished:(id)sender;

- (NSArray *)walkableAdjacentTilesCoordForTileCoord:(CGPoint)tileCoord;
-(BOOL)isWallAtTileCoord:(CGPoint)tileCoord;
-(BOOL)isValidTileCoord:(CGPoint)tileCoord;

@end
