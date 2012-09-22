//
//  CCActor.m
//  TileGame
//
//  Created by Shingo Tamura on 4/09/12.
//
//

#import "CCActor.h"

@implementation CCActor

@synthesize speed = _speed;
@synthesize light = _light;

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

-(void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray*)listOfGameObjects {
    if (self.characterState == kStateDead) 
        return; // Nothing to do if Actor is dead
}

-(id)init {
    if( (self = [super init]) )
    {
        self.speed = 0.0f;
        self.light = 0.0f;
        self.position = CGPointZero;
    }
    return self;
}

@end
