//
//  Powerup.h
//  TileGame
//
//  Created by Shingo Tamura on 1/09/12.
//
//

#import "cocos2d.h"

@class CCActor;

@interface Powerup : CCSprite {
    NSString *_key;
    int _remainingUsage;
}

@property (nonatomic, assign) NSString *key;
@property (nonatomic, assign) int remainingUsage;

-(void)applyPowerup: (CCActor*)target;
-(void)use: (CCActor*)target;

@end
