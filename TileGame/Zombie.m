//
//  Zombie.m
//  TileGame
//
//  Created by Sam Christian Lee on 9/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Zombie.h"
#import "HelloWorldLayer.h"

@interface Zombie ()

@property (nonatomic, retain) NSMutableArray *spOpenSteps;
@property (nonatomic, retain) NSMutableArray *spClosedSteps;
@property (nonatomic, retain) NSMutableArray *shortestPath;
@property (nonatomic, retain) CCAction *currentStepAction;
@property (nonatomic, retain) NSValue *pendingMove;

- (void)insertInOpenSteps:(ShortestPathStep *)step;
- (int)computeHScoreFromCoord:(CGPoint)fromCoord toCoord:(CGPoint)toCoord;
- (int)costToMoveFromStep:(ShortestPathStep *)fromStep toAdjacentStep:(ShortestPathStep *)toStep;
- (void)constructPathAndStartAnimationFromStep:(ShortestPathStep *)step;
- (void)popStepAndAnimate;
- (void)runAnimation:(CCAnimation *)animation;

@end

@implementation Zombie

@synthesize delegate;
@synthesize myDebugLabel;
@synthesize spOpenSteps;
@synthesize spClosedSteps;
@synthesize shortestPath;
@synthesize currentStepAction;
@synthesize pendingMove;

-(void)dealloc {
	delegate = nil;
	myDebugLabel = nil;
	[spOpenSteps release]; spOpenSteps = nil;
	[spClosedSteps release]; spClosedSteps = nil;
	[shortestPath release]; shortestPath = nil;
	[currentStepAction release]; currentStepAction = nil;
	[pendingMove release]; pendingMove = nil;
	[super dealloc];
}

#pragma mark Zombified Animation

- (void)runAnimation:(CCAnimation *)animation
{
    if (_curAnimation == animation) return;
    _curAnimation = animation;
    
    if (_curAnimate != nil) {
        [self stopAction:_curAnimate];
    }
    
    _curAnimate = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
    [self runAction:_curAnimate];
}

- (CCAnimation *)createZombifiedAnimation:(NSString *)animType
{
    CCAnimation *animation = [CCAnimation animation];
    for(int i = 1; i <= 2; ++i) {
        [animation addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                             [NSString stringWithFormat:@"dog_%@_%d.png", animType, i]]];
    }
    animation.delay = 0.2;
    return animation;
}

#pragma mark PathFinding

// Insert a path step (ShortestPathStep) in the ordered open steps list (spOpenSteps)
- (void)insertInOpenSteps:(ShortestPathStep *)step
{
	int stepFScore = [step fScore];
	int count = [self.spOpenSteps count];
	int i = 0;
	for (; i < count; i++) {
		// if the step F score's is lower or equals to the step at index i
		if (stepFScore <= [[self.spOpenSteps objectAtIndex:i] fScore]) {
			// Then we found the index at which we have to insert the new step
			break;
		}
	}
	// Insert the new step at the good index to preserve the F score ordering
	[self.spOpenSteps insertObject:step atIndex:i];
}

// Compute the cost of moving from a step to an adjecent one
- (int)costToMoveFromStep:(ShortestPathStep *)fromStep toAdjacentStep:(ShortestPathStep *)toStep
{
	return ((fromStep.position.x != toStep.position.x) && (fromStep.position.y != toStep.position.y)) ? 14 : 10;
}

// Compute the H score from a position to another (from the current position to the final desired position
- (int)computeHScoreFromCoord:(CGPoint)fromCoord toCoord:(CGPoint)toCoord
{
	// Manhattan distance
	return abs(toCoord.x - fromCoord.x) + abs(toCoord.y - fromCoord.y);
}

// Go backward from a step (the final one) to reconstruct the shortest computed path
- (void)constructPathAndStartAnimationFromStep:(ShortestPathStep *)step
{
	self.shortestPath = [NSMutableArray array];
	
	do {
		if (step.parent != nil) { // Don't add the last step which is the start position (remember we go backward, so the last one is the origin position ;-)
			[self.shortestPath insertObject:step atIndex:0]; // Always insert at index 0 to reverse the path
		}
		step = step.parent; // Go backward
	} while (step != nil); // Until there is not more parent
	
	[self popStepAndAnimate];
}

// Callback which will be called at the end of each animated step along the computed path
- (void)popStepAndAnimate
{	
    self.currentStepAction = nil;
	
    // Check if there is a pending move
    if (self.pendingMove != nil) {
        CGPoint moveTarget = [pendingMove CGPointValue];
        self.pendingMove = nil;
		self.shortestPath = nil;
        [self chaseHero:moveTarget];
        return;
    }
    
	// Check if there is still shortestPath 
	if (self.shortestPath == nil) {
		return;
	}
	
	//Get reference to layer's tile properties (double because layer is spriteBatchNode's parent)
	HelloWorldLayer *layer = (HelloWorldLayer *)[[self parent] parent];
	
	CGPoint currentPosition = [layer tileCoordForPosition:self.position];
	
	// Check if there remains path steps to go trough
	if ([self.shortestPath count] == 0) {
		self.shortestPath = nil;
		return;
	}
	
	// Get the next step to move to
	ShortestPathStep *s = [self.shortestPath objectAtIndex:0];
	
	// Animate zombie
	CGPoint futurePosition = s.position;
	CGPoint diff = ccpSub(futurePosition, currentPosition);
	if (abs(diff.x) > abs(diff.y)) {
		if (diff.x > 0) {
			[self runAnimation:_facingRightAnimation];
		}
		else {
			[self runAnimation:_facingLeftAnimation];
		}    
	}
	else {
		if (diff.y > 0) {
			[self runAnimation:_facingForwardAnimation];
		}
		else {
			[self runAnimation:_facingBackAnimation];
		}
	}
	
	
	// Prepare the action and the callback
	id moveAction = [CCMoveTo actionWithDuration:1.0f position:[layer positionForTileCoord:s.position]];
	id moveCallback = [CCCallFunc actionWithTarget:self selector:@selector(popStepAndAnimate)]; // set the method itself as the callback
	self.currentStepAction = [CCSequence actions:moveAction, moveCallback, nil];
	
	// Remove the step
	[self.shortestPath removeObjectAtIndex:0];
	
	// Play actions
	[self runAction:currentStepAction];
}

#pragma mark Deft Zombie?

-(CGRect)eyesightBoundingBox {
    CGRect zombieSightBoundingBox;
    CGRect zombieBoundingBox = [self adjustedBoundingBox];
	zombieSightBoundingBox = CGRectMake(zombieBoundingBox.origin.x - zombieBoundingBox.size.width*5.0f, 
                                           zombieBoundingBox.origin.y - zombieBoundingBox.size.height*5.0f,
                                           zombieBoundingBox.size.width*10.0f, 
                                           zombieBoundingBox.size.height*10.0f);
	return zombieSightBoundingBox;
}

-(void)chaseHero:(CGPoint)target
{
	//Start by stopping current moving action
	if (currentStepAction)
	{
		self.pendingMove = [NSValue valueWithCGPoint:target];
		return;
	}
	
	//Initialize shortest path properties
	self.spOpenSteps = [NSMutableArray array];
	self.spClosedSteps = [NSMutableArray array];
	self.shortestPath = nil;
	
	//Get reference to layer's tile properties (double because layer is spriteBatchNode's parent)
	HelloWorldLayer *layer = (HelloWorldLayer *)[[self parent] parent];
	CGPoint fromTileCoor = [layer tileCoordForPosition:self.position];
    CGPoint toTileCoord = [layer tileCoordForPosition:target];

	//Check if zombie already reached target
	if (CGPointEqualToPoint(fromTileCoor, toTileCoord)) {
		return;
	}
	
	// Start by adding the from position to the open list
	[self insertInOpenSteps:[[[ShortestPathStep alloc] initWithPosition:fromTileCoor] autorelease]];
	
	do 
	{
		// Because the list is ordered, the first step is always the one with the lowest F cost
		ShortestPathStep *currentStep = [self.spOpenSteps objectAtIndex:0];
		
		[self.spClosedSteps addObject:currentStep]; // Add the current step to the closed set
		[self.spOpenSteps removeObjectAtIndex:0]; // Remove it from the open list
		
		// If currentStep is at the desired tile coordinate, we have done
		if (CGPointEqualToPoint(currentStep.position, toTileCoord)) {
			[self constructPathAndStartAnimationFromStep:currentStep];
			self.spOpenSteps = nil; // Set to nil to release unused memory
			self.spClosedSteps = nil; // Set to nil to release unused memory
			break;
		}
		
		// Get the adjacent tiles coord of the current step
		NSArray *adjSteps = [layer walkableAdjacentTilesCoordForTileCoord:currentStep.position];
		for (NSValue *v in adjSteps) {
			ShortestPathStep *step = [[ShortestPathStep alloc] initWithPosition:[v CGPointValue]];
			
			// Check if the step isn't already in the closed set 
			if ([self.spClosedSteps containsObject:step]) {
				[step release]; // Must releasing it to not leaking memory ;-)
				continue; // Ignore it
			}		
			
			// Compute the cost form the current step to that step
			int moveCost = [self costToMoveFromStep:currentStep toAdjacentStep:step];
			
			// Check if the step is already in the open list
			NSUInteger index = [self.spOpenSteps indexOfObject:step];
			
			// if not on the open list, so add it
			if (index == NSNotFound) { 
				// Set the current step as the parent
				step.parent = currentStep;
				// The G score is equal to the parent G score + the cost to move from the parent to it
				step.gScore = currentStep.gScore + moveCost;
				step.hScore = [self computeHScoreFromCoord:step.position toCoord:toTileCoord];
				
				[self insertInOpenSteps:step];
				[step release];
			}
			else {
				// Already in the open list
				[step release]; // Release the freshly created one
				step = [self.spOpenSteps objectAtIndex:index]; // To retrieve the old one (which has its scores already computed ;-)
				
				// Check to see if the G score for that step is lower if we use the current step to get there
				if ((currentStep.gScore + moveCost) < step.gScore) {
					
					// The G score is equal to the parent G score + the cost to move from the parent to it
					step.gScore = currentStep.gScore + moveCost;
					
					// Because the G Score has changed, the F score may have changed too
					// So to keep the open list ordered we have to remove the step, and re-insert it with
					// the insert function which is preserving the list ordered by F score
					
					// We have to retain it before removing it from the list
					[step retain];
					
					// Now we can removing it from the list without be afraid that it can be released
					[self.spOpenSteps removeObjectAtIndex:index];
					
					// Re-insert it with the function which is preserving the list ordered by F score
					[self insertInOpenSteps:step];
					
					// Now we can release it because the oredered list retain it
					[step release];
				}			
			}
		}
	} while ([self.spOpenSteps count] > 0);
	
}

-(void)changeState:(CharacterStates)newState {
    if (characterState == kStateDead)
        return; // No need to change state further once I am dead
    
    //[self stopAllActions];
    characterState = newState;
    CGPoint target;
    switch (newState) {
        case kStateSpawning:
			break;
        case kStateWalking:
            //CCLOG(@"Zombie -> Changing State to Walking");
            if (isHeroWithinBoundingBox) 
                break;
			break;
        case kStateAttacking:
			//CCLOG(@"Zombie -> Changing State to Attacking");
			//Get hero's current position
			target = CGPointMake(hero.position.x, hero.position.y);
			//CCLOG(@"target position: %d, %d", hero.position.x, hero.position.y);
			[self chaseHero:target];
            break;
		case kStateDead:
            CCLOG(@"Zombie -> Going to Dead State");
            break;
        default:
            CCLOG(@"Zombie -> Unknown CharState %d", characterState);
            break;
    }
}

-(void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray*)listOfGameObjects {

	
    if ((characterState != kStateDead) && (characterHealth <= 0)) {
		[self changeState:kStateDead];
        return;
    }
    
    hero = (GameCharacter*)[[self parent] getChildByTag:kHeroSpriteTagValue];
    CGRect heroBoundingBox = [hero adjustedBoundingBox];
	CGRect zombieBoundingBox = [self adjustedBoundingBox];
	CGRect zombieSightBoundingBox = [self eyesightBoundingBox];
    
	isHeroWithinBoundingBox = CGRectIntersectsRect(heroBoundingBox, zombieBoundingBox);
    isHeroWithinSight = CGRectIntersectsRect(heroBoundingBox, zombieSightBoundingBox)? YES : NO;
	
	//[self stopAllActions];
	
    //if ([self numberOfRunningActions] == 0) {
        if (characterState == kStateDead) {
            [self setVisible:NO];
            [self removeFromParentAndCleanup:YES];
        } else if (isHeroWithinSight) {
			CCLOG(@"hero coordinates: (%f, %f)", hero.position.x, hero.position.y);
			CCLOG(@"zombie coordinates: (%f, %f)", self.position.x, self.position.y);
            [self changeState:kStateAttacking];
        }  else {
            [self changeState:kStateWalking];
        }
    //} 
	 
}

-(void)scheduledUpdateMethod
{
	if ((characterState != kStateDead) && (characterHealth <= 0)) {
		[self changeState:kStateDead];
        return;
    }
    
    hero = (GameCharacter*)[[self parent] getChildByTag:kHeroSpriteTagValue];
    CGRect heroBoundingBox = [hero adjustedBoundingBox];
	CGRect zombieBoundingBox = [self adjustedBoundingBox];
	CGRect zombieSightBoundingBox = [self eyesightBoundingBox];
    
	isHeroWithinBoundingBox = CGRectIntersectsRect(heroBoundingBox, zombieBoundingBox);
    isHeroWithinSight = CGRectIntersectsRect(heroBoundingBox, zombieSightBoundingBox)? YES : NO;
	
	//[self stopAllActions];
	
    //if ([self numberOfRunningActions] == 0) {
	if (characterState == kStateDead) {
		[self setVisible:NO];
		[self removeFromParentAndCleanup:YES];
	} else if (isHeroWithinSight) {
		//CCLOG(@"hero coordinates: (%f, %f)", hero.position.x, hero.position.y);
		//CCLOG(@"zombie coordinates: (%f, %f)", self.position.x, self.position.y);
		[self changeState:kStateAttacking];
	}  else {
		[self changeState:kStateWalking];
	}
    //} 
	
}

-(id) init
{
    if((self=[super init]))
    {
        isHeroWithinBoundingBox = NO; 
        isHeroWithinSight = NO;
		gameObjectType = kEnemyTypeZombie;
		
		_facingForwardAnimation = [[self createZombifiedAnimation:@"forward"] retain];
        _facingBackAnimation = [[self createZombifiedAnimation:@"back"] retain];
        _facingLeftAnimation = [[self createZombifiedAnimation:@"left"] retain];
        _facingRightAnimation = [[self createZombifiedAnimation:@"right"] retain];
		
		//[self schedule:@selector(scheduledUpdateMethod) interval:1.0f];
		
    }
    return self;
}

@end
