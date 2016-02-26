//
//  ExtensionDelegate.m
//  Chill WatchOS 2 Extension
//
//  Created by Михаил Луцкий on 22.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import "ExtensionDelegate.h"
@implementation ExtensionDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([WCSession isSupported]) {
                if ([WCSession isSupported]) {
                    WCSession *defaultSession = [WCSession defaultSession];
                    defaultSession.delegate = self;
                    [defaultSession activateSession];
                }
            }
        });
    }
    return self;
}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSArray *favorites = userInfo[@"Favorites"];
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    [userCache setObject:favorites forKey:@"FavoritesArray"];
}

@end
