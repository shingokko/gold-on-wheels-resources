//
//  GameOverScene.m
//  TileGame
//
//  Created by Shingo Tamura on 12/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameOverScene.h"
#import "GamePlayRenderingLayer.h"

@implementation GameOverScene
@synthesize layer = _layer;

- (id)init {
    if ((self = [super init])) {
        self.layer = [GameOverLayer node];
        [self addChild:_layer];
    }
    return self;
}

- (void)dealloc {
    [_layer release];
    _layer = nil;
    [super dealloc];
}
@end

@implementation GameOverLayer

@synthesize label = _label;


-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSLog(@"ccTouchBegan fired");
	return YES;
}

-(id) init {
    if ((self=[super initWithColor:ccc4(255, 255, 255, 255)])) {
        self.isTouchEnabled = YES;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.label = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:32];
        _label.color = ccc3(0, 0, 0);
        _label.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:_label];
        
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:3], [CCCallFunc actionWithTarget:self selector:@selector(gameOverDone)], nil]];
        
        NSLog(@"GameOverLayer initialised");
        
    }
    return self;
}

-(void)gameOverDone {
    [[CCDirector sharedDirector] replaceScene:[GamePlayRenderingLayer scene]];
}

-(void)dealloc {
    [_label release];
    _label = nil;
    [super dealloc];
}

@end