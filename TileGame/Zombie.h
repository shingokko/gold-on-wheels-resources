//
//  Zombie.h
//  TileGame
//
//  Created by Sam Christian Lee on 9/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameCharacter.h"
#import "ShortestPathStep.h"
#import "Constants.h"
#import "CCHero.h"

@interface Zombie : GameCharacter {
    CCHero *hero;
	BOOL isHeroWithinBoundingBox;
    BOOL isHeroWithinSight;
	
    id <GameplayLayerDelegate> delegate;
    CCLabelBMFont *myDebugLabel;
	
	CCAnimation *_facingForwardAnimation;
    CCAnimation *_facingBackAnimation;
    CCAnimation *_facingLeftAnimation;
    CCAnimation *_facingRightAnimation;
	CCAnimation *_curAnimation;
    CCAnimate *_curAnimate;
	
@private
	NSMutableArray *spOpenSteps;
	NSMutableArray *spClosedSteps;
	NSMutableArray *shortestPath;
	CCAction *currentStepAction;
	NSValue *pendingMove;
}

@property (nonatomic,assign) id <GameplayLayerDelegate> delegate;
@property (nonatomic,assign) CCLabelBMFont *myDebugLabel;

-(void)chaseHero:(CGPoint)target;

@end