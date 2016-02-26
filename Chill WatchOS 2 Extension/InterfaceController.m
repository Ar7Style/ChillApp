//
//  InterfaceController.m
//  Chill WatchOS 2 Extension
//
//  Created by Михаил Луцкий on 22.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import "InterfaceController.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "UserCache.h"
@interface InterfaceController() <WCSessionDelegate>

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    if ([NSUserDefaults isAprooved] && [NSUserDefaults isAuth]) {
        NSArray *array1=[[NSArray alloc] initWithObjects:@"ContactsIC", nil];
        [WKInterfaceController reloadRootControllersWithNames:array1 contexts:nil];
    }
    else {
        WCSession *session = [WCSession defaultSession];
        NSError *error;
        [session updateApplicationContext:@{@"type":@"getAuth"} error:&error];
    }
}

- (void) session:(nonnull WCSession *)session didReceiveApplicationContext:(nonnull NSDictionary<NSString *,id> *)applicationContext {
    if ([[applicationContext objectForKey:@"isAuth"] isEqualToString:@"true"] && [[applicationContext objectForKey:@"isApproved"] isEqualToString:@"true"]) {
        [NSUserDefaults changeAprooved:true];
        [NSUserDefaults changeAuth:true];
        [NSUserDefaults setValue:[applicationContext objectForKey:@"userID"] forKey:@"id_user"];
        [NSUserDefaults setValue:[applicationContext objectForKey:@"token"] forKey:@"token"];
        NSArray *array1=[[NSArray alloc] initWithObjects:@"ContactsIC", nil];
        [WKInterfaceController reloadRootControllersWithNames:array1 contexts:nil];
    }
    NSLog(@"%@", applicationContext);
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)recheckAction {
}
@end



