//
//  CHLWatchWCManager.h
//  Chill
//
//  Created by Ivan Grachev on 2/27/16.
//  Copyright © 2016 Chlil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface CHLWatchWCManager : NSObject<WCSessionDelegate>

+ (id)sharedManager;
- (void)setupSession;
- (void)requestAuth;

@end
