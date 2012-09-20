//
//  CommonProtocol.h
//  TileGame
//
//  Created by Sam Christian Lee on 9/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

typedef enum {
    kStateSpawning,
    kStateIdle,
    kStateCrouching,
    kStateStandingUp,
    kStateWalking,
    kStateAttacking,
    kStateJumping,
    kStateBreathing,
    kStateTakingDamage,
    kStateDead,
    kStateTraveling,
    kStateRotating, 
    kStateDrilling,
    kStateAfterJumping
} CharacterStates;

typedef enum {
	kObjectTypeNone,
	kHeroType,
    kEnemyTypeZombie
} GameObjectType;

@protocol GameplayLayerDelegate

-(void)createObjectOfType:(GameObjectType)objectType 
               withHealth:(int)initialHealth
               atLocation:(CGPoint)spawnLocation 
               withZValue:(int)ZValue;

@end
