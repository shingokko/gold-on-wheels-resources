//
//  GameObject.h
//  TileGame
//
//  Created by Sam Christian Lee on 9/22/12.
//  Copyright 2012 GameCurry. All rights reserved.
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
-(void)updateStateWithDeltaTime:(ccTime)deltaTime andGameObject:(GameObject*)gameObject;
-(CGRect)adjustedBoundingBox;


@end
