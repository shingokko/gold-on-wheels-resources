//
//  Powerup.m
//  TileGame
//
//  Created by Shingo Tamura on 1/09/12.
//
//

#import "Powerup.h"

@implementation Powerup

@synthesize key = _key;
@synthesize remainingUsage = _remainingUsage;

-(id)init {
    if( (self = [super init]) )
    {
        _key = @"Default";
        _remainingUsage = 1;
    }
    return self;
}

-(void)applyPowerup: (CCActor*)target {
}

-(void)use:(CCActor *)target {
    if (_remainingUsage == 0) {
        return;
    }
    
    [self applyPowerup:target];
    
    _remainingUsage -= 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"usedOnce" object:self ];
    
    // if no remainig usage, raise used up event
    if (_remainingUsage == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"usedUp" object:self ];
    }
}

@end
