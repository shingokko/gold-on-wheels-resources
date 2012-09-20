//
//  GameObject.m
//  TileGame
//
//  Created by Sam Christian Lee on 9/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
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

-(void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray*)listOfGameObjects {
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
