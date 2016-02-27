//
//  InterfaceController.m
//  Chill WatchOS 2 Extension
//
//  Created by Михаил Луцкий on 22.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import "InterfaceController.h"
#import "CHLWatchWCManager.h"
#import "UserCache.h"

@interface InterfaceController ()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    if ([NSUserDefaults isAprooved] && [NSUserDefaults isAuth]) {
        [self reloadWithContactsController];
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadWithContactsController) name:@"AuthOK" object:nil];
        [[CHLWatchWCManager sharedManager] requestAuth];
    }
}

- (void)reloadWithContactsController {
    NSArray *array = [[NSArray alloc] initWithObjects:@"ContactsIC", nil];
    [WKInterfaceController reloadRootControllersWithNames:array contexts:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)recheckAction {
    [[CHLWatchWCManager sharedManager] requestAuth];
}

- (void)deinit {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end



