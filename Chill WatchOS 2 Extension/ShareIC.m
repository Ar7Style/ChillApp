//
//  ShareICInterfaceController.m
//  Chill
//
//  Created by Михаил Луцкий on 22.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import "ShareIC.h"
#import "UserCache.h"
@interface ShareIC ()

@end

@implementation ShareIC

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    if (![NSUserDefaults showGuide]) {
        [NSUserDefaults changeGuide:true];
        [self presentControllerWithName:@"HelpIC" context:nil];
    }
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



