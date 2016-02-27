//
//  ExtensionDelegate.m
//  Chill WatchOS 2 Extension
//
//  Created by Михаил Луцкий on 22.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import "ExtensionDelegate.h"
#import "CHLWatchWCManager.h"
@implementation ExtensionDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([WCSession isSupported]) {
                [[CHLWatchWCManager sharedManager] setupSession];
            }
        });
    }
    return self;
}

@end
