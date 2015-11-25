//
//  IconsIC.m
//  Chill
//
//  Created by Михаил Луцкий on 23.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import "IconsIC.h"

@interface IconsIC ()

@end

@implementation IconsIC

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.title = @"";
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



