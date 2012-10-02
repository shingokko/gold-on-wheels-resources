//
//  Lightup.m
//  TileGame
//
//  Created by Shingo Tamura on 4/09/12.
//
//

#import "Lightup.h"
#import "CCActor.h"

@implementation Lightup

@synthesize percentage = _percentage;

-(id)init {
    if( (self = [super init]) )
    {
        _key = @"Lightup";
        _percentage = 1.2f; // increase by 20%
    }
    return self;
}

-(void)applyPowerup: (CCActor*)target {
    target.light *= _percentage;
}

@end

