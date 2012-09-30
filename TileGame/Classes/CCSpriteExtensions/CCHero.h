//
//  CCHero.h
//  TileGame
//
//  Created by Shingo Tamura on 15/09/12.
//
//

#import "CCActor.h"
#import "CommonProtocol.h"

@interface CCHero : CCActor
{
    FacingDirection _facingDirection;
    CCAnimation *_frontAnim;
    CCAnimation *_backAnim;
    CCAnimation *_sideAnim;

}

@property (nonatomic, retain) CCAnimation *frontAnim;
@property (nonatomic, retain) CCAnimation *backAnim;
@property (nonatomic, retain) CCAnimation *sideAnim;

@property (nonatomic, assign) FacingDirection facingDirection;

@end
