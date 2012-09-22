//
//  TitleScreenScene.h
//  TileGame
//
//  Created by Shingo Tamura on 26/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface TitleScreenLayer : CCLayerColor {
}
@end

@interface TitleScreenScene : CCScene {
    TitleScreenLayer *layer;
}
@property (nonatomic, retain) TitleScreenLayer *layer;
@end