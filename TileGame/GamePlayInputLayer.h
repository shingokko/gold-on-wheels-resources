//
//  GamePlayerInputLayer.h
//  TileGame
//
//  Created by Shingo Tamura on 8/09/12.
//
//

#import "cocos2d.h"

@class SneakyJoystick;
@class GamePlayRenderingLayer;

@interface GamePlayInputLayer : CCLayer
{
    CCLabelTTF *_label;
    GamePlayRenderingLayer *_gameLayer;
    
	SneakyJoystick *leftJoystick;
	SneakyJoystick *rightJoystick;
    
    ccTime _tmpMovingDelta;
    ccTime _tmpAttackingDelta;
    ccTime _movingThreshold;
    ccTime _attackingThreshold;
}

-(void)melonCountChanged:(int)melonCount;

@property (nonatomic, assign) GamePlayRenderingLayer *gameLayer;
@property (nonatomic, assign) ccTime movingThreshold;
@end

