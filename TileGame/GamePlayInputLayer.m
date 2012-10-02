//
//  GamePlayerInputLayer.m
//  TileGame
//
//  Created by Shingo Tamura on 8/09/12.
//
//

#import "GamePlayInputLayer.h"
#import "GamePlayRenderingLayer.h"
#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedJoystickExample.h"
#import "SneakyJoystickSkinnedDPadExample.h"
#import "SneakyButton.h"
#import "SneakyButtonSkinnedBase.h"
#import "ColoredCircleSprite.h"
#import "CCActor.h"
#import "CCHero.h"

@implementation GamePlayInputLayer

@synthesize movingThreshold = _movingThreshold;

-(CGPoint) applyVelocity: (CGPoint)velocity position:(CGPoint)position delta:(ccTime)delta {
	return CGPointMake(position.x + velocity.x * delta, position.y + velocity.y * delta);
}

-(void)applyDirectionalJoystick:(SneakyJoystick*)joystick toNode:(CCHero*)node forTimeDelta:(ccTime)delta
{
	// you can create a velocity specific to the node if you wanted, just supply a different multiplier
	// which will allow you to do a parallax scrolling of sorts
	//CGPoint scaledVelocity = ccpMult(joystick.velocity, 240.0f);
    
    if (joystick.isActive) {
        // apply the scaled velocity to the position over delta
        //[_gameLayer moveHero:node.position];
        //node.position = [self applyVelocity:scaledVelocity position:node.position delta:delta];
        
        _tmpMovingDelta += delta;
        
        if (_tmpMovingDelta >= _movingThreshold) {
            CGPoint newPosition = ccp(node.position.x, node.position.y);
            
            _tmpMovingDelta = 0.0f;
            
            FacingDirection dir;
            if (joystick.degrees > 45.0f && joystick.degrees < 135.0f) {
                // up
                dir = kFacingUp;
                newPosition.y += node.speed;
            }
            else if (joystick.degrees > 135.0f && joystick.degrees < 225.0f) {
                // left
                dir = kFacingLeft;
                newPosition.x -= node.speed;
            }
            else if (joystick.degrees > 225.0f && joystick.degrees < 315.0f) {
                // down
                dir = kFacingDown;
                newPosition.y -= node.speed;
            }
            else {
                // right
                dir = kFacingRight;
                newPosition.x += node.speed;
            }
            
            [_gameLayer moveHero:newPosition facing:dir];
        }
    }
}
-(void)applyAttackingJoystick:(SneakyJoystick*)joystick toNode:(CCNode*)node forTimeDelta:(ccTime)delta
{
	// you can create a velocity specific to the node if you wanted, just supply a different multiplier
	// which will allow you to do a parallax scrolling of sorts
	//CGPoint scaledVelocity = ccpMult(joystick.velocity, 240.0f);
    
    if (joystick.isActive) {
        
        _tmpAttackingDelta += delta;
        
        if (_tmpAttackingDelta >= _attackingThreshold) {
            CGPoint newPosition = ccp(node.position.x, node.position.y);
            newPosition.x += joystick.stickPosition.x;
            newPosition.y += joystick.stickPosition.y;
            
            _tmpAttackingDelta = 0.0f;
            [_gameLayer throwProjectile:newPosition];
        }
    }
}


-(void)update:(ccTime)deltaTime {
    // need to add [glView setMultipleTouchEnabled:YES]; to AppDelegate.m to enable multi-touch
    [self applyDirectionalJoystick:leftJoystick toNode:_gameLayer.player forTimeDelta:deltaTime];
}

-(void) onEnter
{
    CCLOG(@"HelloWorldHud onEnter.");
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:2 swallowsTouches:YES];
    [super onEnter];
}
-(void) onExit
{
    CCLOG(@"HelloWorldHud onExit.");
    [[CCTouchDispatcher sharedDispatcher] removeDelegate: self];
    [super onExit];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CCLOG(@"HelloWorldHud touched.");
	return NO;
}

-(void)initJoystickAndButtons {
    // initialize a joystick
    SneakyJoystickSkinnedBase *leftJoy = [[[SneakyJoystickSkinnedBase alloc] init] autorelease];
    leftJoy.position = ccp(64, 64);
    leftJoy.backgroundSprite = [CCSprite spriteWithFile:@"wheel.png"];
    leftJoy.thumbSprite = [CCSprite spriteWithFile:@"lever.png"];
    leftJoy.joystick = [[SneakyJoystick alloc] initWithRect:CGRectMake(0,0,128,128)];
    leftJoystick = [leftJoy.joystick retain];
    
    [self addChild:leftJoy z:2];}

-(id) init
{
    if ((self = [super init])) {
        self.isTouchEnabled = YES;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        _label = [CCLabelTTF labelWithString:@"0" dimensions:CGSizeMake(50, 30)
                                   alignment:UITextAlignmentRight fontName:@"Verdana-Bold"
                                    fontSize:26.0];
        
        _label.color = ccc3(255,255,255);
        int margin = 10;
        _label.position = ccp((winSize.width/2) - (_label.contentSize.width/2)
                              - margin, _label.contentSize.height/2 + margin);
        
        [self addChild:_label];
        
        [self initJoystickAndButtons];
        [self scheduleUpdate];
        
        _movingThreshold = 0.2f;
        _attackingThreshold = 0.8f;
        
        _tmpAttackingDelta = _attackingThreshold;
        _tmpMovingDelta = _movingThreshold;
    }
    return self;
}

- (void)melonCountChanged:(int)melonCount {
    [_label setString:[NSString stringWithFormat:@"%d", melonCount]];
}

@synthesize gameLayer = _gameLayer;

@end
