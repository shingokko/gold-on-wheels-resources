//
//  Lightup.h
//  TileGame
//
//  Created by Shingo Tamura on 4/09/12.
//
//

#import "Powerup.h"

@interface Lightup: Powerup {
    CGFloat _percentage;
}

@property(nonatomic, assign) CGFloat percentage;

@end
