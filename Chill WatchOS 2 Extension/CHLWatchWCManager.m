//
//  CHLWatchWCManager.m
//  Chill
//
//  Created by Ivan Grachev on 2/27/16.
//  Copyright © 2016 Chlil. All rights reserved.
//

#import "CHLWatchWCManager.h"
#import "UserCache.h"

@implementation CHLWatchWCManager

+ (id)sharedManager {
    static CHLWatchWCManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void)requestAuth {
    WCSession *session = [WCSession defaultSession];
    NSError *error;
    [session updateApplicationContext:@{@"type":@"getAuth"} error:&error];
}

- (void)setupSession {
    if ([WCSession isSupported]) {
        WCSession *defaultSession = [WCSession defaultSession];
        defaultSession.delegate = self;
        [defaultSession activateSession];
    }
}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSArray *favorites = userInfo[@"Favorites"];
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    [userCache setObject:favorites forKey:@"FavoritesArray"];
}

- (void) session:(nonnull WCSession *)session didReceiveApplicationContext:(nonnull NSDictionary<NSString *,id> *)applicationContext {
    if ([[applicationContext objectForKey:@"isAuth"] isEqualToString:@"true"] && [[applicationContext objectForKey:@"isApproved"] isEqualToString:@"true"]) {
        [NSUserDefaults changeAprooved:true];
        [NSUserDefaults changeAuth:true];
        [NSUserDefaults setValue:[applicationContext objectForKey:@"userID"] forKey:@"id_user"];
        [NSUserDefaults setValue:[applicationContext objectForKey:@"token"] forKey:@"token"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthOK" object:nil];
    }
    NSLog(@"%@", applicationContext);
}

@end
