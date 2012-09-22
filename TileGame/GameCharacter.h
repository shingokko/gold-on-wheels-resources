//
//  GameCharacter.h
//  TileGame
//
//  Created by Sam Christian Lee on 9/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObject.h"

@interface GameCharacter : GameObject {
	int characterHealth;
	CharacterStates characterState;
}

@property (readwrite) int characterHealth;
@property (readwrite) CharacterStates characterState; 

@end
