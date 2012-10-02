//
//  GameObject.m
//  TileGame
//
//  Created by Sam Christian Lee on 9/22/12.
//  Copyright 2012 GameCurry. All rights reserved.
//

#import "GameObject.h"

@implementation GameObject

@synthesize screenSize;
@synthesize gameObjectType;

-(CGRect)adjustedBoundingBox {
    return [self boundingBox];
}

-(void)changeState:(CharacterStates)newState {
    //CCLOG(@"GameObject->changeState method should be overriden");
}

-(void)updateStateWithDeltaTime:(ccTime)deltaTime andGameObject:(GameObject*)gameObject {
    //CCLOG(@"updateStateWithDeltaTime method should be overriden");
}

-(id)init {
	if((self=[super init])){
        CCLOG(@"GameObject init");
        screenSize = [CCDirector sharedDirector].winSize;
		gameObjectType = kObjectTypeNone;
    }
    return self;
}

@end
