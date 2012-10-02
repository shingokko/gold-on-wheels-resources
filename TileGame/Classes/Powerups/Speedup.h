//
//  Speedup.h
//  TileGame
//
//  Created by Shingo Tamura on 1/09/12.
//
//

#import "Powerup.h"

@interface Speedup: Powerup {
    CGFloat _percentage;
}

@property(nonatomic, assign) CGFloat percentage;

@end
