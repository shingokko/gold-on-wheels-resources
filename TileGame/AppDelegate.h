//
//  AppDelegate.h
//  TileGame
//
//  Created by Shingo Tamura on 5/07/12.
//  Copyright Test 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
