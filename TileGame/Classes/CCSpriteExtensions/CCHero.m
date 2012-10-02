//
//  CCHero.m
//  TileGame
//
//  Created by Shingo Tamura on 15/09/12.
//
//

#import "CCHero.h"

@implementation CCHero

@synthesize frontAnim = _frontAnim;
@synthesize backAnim = _backAnim;
@synthesize sideAnim = _sideAnim;
@synthesize facingDirection = _facingDirection;

-(void) dealloc {
    [_frontAnim release];
    [_backAnim release];
    [_sideAnim release];
    
    [super dealloc];
}

-(id) init
{
    if( (self=[super init]) )
    {
        _facingDirection = kFacingDown;
		self.gameObjectType = kHeroType;
    }
    return self;
}

@end
