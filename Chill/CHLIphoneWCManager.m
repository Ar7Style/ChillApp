//
//  CHLIphoneWCManager.m
//  Chill
//
//  Created by Ivan Grachev on 2/26/16.
//  Copyright © 2016 Chlil. All rights reserved.
//

#import "CHLIphoneWCManager.h"
#import "UserCache.h"

@implementation CHLIphoneWCManager

+ (id)sharedManager {
    static CHLIphoneWCManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)setupSession {
    if ([WCSession class]) {
        if ([WCSession isSupported]) {
            WCSession *defaultSession = [WCSession defaultSession];
            defaultSession.delegate = self;
            [defaultSession activateSession];
        }
    }
}

- (void)sendFavoriteIconsNames:(NSArray *)names {
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    [userCache setObject:names forKey:@"FavoritesArray"];
    [userCache synchronize];
    [[WCSession defaultSession] transferUserInfo:@{@"Favorites" : names.copy}];
}

- (void) session:(nonnull WCSession *)session didReceiveApplicationContext:(nonnull NSDictionary<NSString *,id> *)applicationContext {
    if ([[applicationContext objectForKey:@"type"] isEqualToString:@"getAuth"]) {
        WCSession *session = [WCSession defaultSession];
        NSError *error;
        [session updateApplicationContext:@{@"userID": [NSUserDefaults userID], @"token":[NSUserDefaults userToken], @"isAuth":@"true", @"isApproved": @"true"} error:&error];
    }
}

- (void)session:(WCSession *)session didFinishUserInfoTransfer:(WCSessionUserInfoTransfer *)userInfoTransfer error:(NSError *)error {
    
}

@end
