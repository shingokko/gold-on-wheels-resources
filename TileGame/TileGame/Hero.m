//
//  Hero.m
//  TileGame
//
//  Created by Sam Christian Lee on 9/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Hero.h"

@implementation Hero

-(void)dealloc
{
	[super dealloc];
}

#pragma mark -
-(void)changeState:(CharacterStates)newState {
    [self stopAllActions];
    CGPoint newPosition;
    [self setCharacterState:newState];
    
    switch (newState) {
        case kStateIdle:
			break;
        case kStateWalking:          
            break;
        case kStateAttacking:
			break;
        case kStateTakingDamage:
            self.characterHealth = self.characterHealth - 10.0f;
			break;
        case kStateDead:
            break;
        default:
            break;
    }
}

#pragma mark -
-(void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray*)listOfGameObjects {
    if (self.characterState == kStateDead) 
        return; // Nothing to do if the Viking is dead
    
}

-(id)init
{
	if ((self = [super init]))
	{
		self.gameObjectType = kHeroType;
	}
	return self;
}

@end
