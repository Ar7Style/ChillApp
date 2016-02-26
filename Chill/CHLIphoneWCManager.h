//
//  CHLIphoneWCManager.h
//  Chill
//
//  Created by Ivan Grachev on 2/26/16.
//  Copyright © 2016 Chlil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface CHLIphoneWCManager : NSObject<WCSessionDelegate>

+ (id)sharedManager;
- (void)setupSession;
- (void)sendFavoriteIconsNames:(NSArray *)names;

@end
