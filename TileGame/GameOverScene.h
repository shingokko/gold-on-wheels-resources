//
//  GameOverScene.h
//  TileGame
//
//  Created by Shingo Tamura on 12/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface GameOverLayer : CCLayerColor {
    CCLabelTTF *_label;
}
@property (nonatomic, retain) CCLabelTTF *label;
@end

@interface GameOverScene : CCScene {
    GameOverLayer *layer;
}
@property (nonatomic, retain) GameOverLayer *layer;
@end