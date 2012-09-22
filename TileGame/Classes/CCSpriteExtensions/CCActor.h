//
//  CCActor.h
//  TileGame
//
//  Created by Shingo Tamura on 4/09/12.
//
//

#import "cocos2d.h"
#import "GameCharacter.h"

@interface CCActor : GameCharacter {
    CGFloat _speed;
    CGFloat _light;
}

@property (nonatomic, assign) CGFloat speed;
@property (nonatomic, assign) CGFloat light;

@end
