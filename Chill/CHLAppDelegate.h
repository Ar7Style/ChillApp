//
//  CHLAppDelegate.h
//  Chill
//
//  Copyright (c) 2014 Mikhail Loutskiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface CHLAppDelegate : UIResponder <UIApplicationDelegate, WCSessionDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
