//
//  GameObject.h
//  TileGame
//
//  Created by Sam Christian Lee on 9/13/12.
//  Modified by Shingo Tamura 9/21/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"
#import "CommonProtocol.h"

@interface GameObject : CCSprite {
    CGSize screenSize;
	GameObjectType gameObjectType;
}

@property (readwrite) CGSize screenSize;
@property (readwrite) GameObjectType gameObjectType;

-(void)changeState:(CharacterStates)newState;
-(void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray*)listOfGameObjects;
-(CGRect)adjustedBoundingBox;

@end
