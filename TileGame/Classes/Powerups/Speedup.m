//
//  Speedup.m
//  TileGame
//
//  Created by Shingo Tamura on 1/09/12.
//
//

#import "Speedup.h"
#import "CCActor.h"

@implementation Speedup

@synthesize percentage = _percentage;

-(id)init {
    if( (self = [super init]) )
    {
        _key = @"Speedup";
        _percentage = 1.1f; // decrease threshold by 10%
    }
    return self;
}

-(void)applyPowerup: (CCActor*)target {
    target.speed *= _percentage;
}

@end

