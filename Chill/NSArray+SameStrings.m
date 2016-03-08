//
//  NSArray+SameStrings.m
//  Chill
//
//  Created by Ivan Grachev on 3/8/16.
//  Copyright © 2016 Chlil. All rights reserved.
//

#import "NSArray+SameStrings.h"

@implementation NSArray (SameStrings)

- (BOOL)sameStrings:(NSArray *)otherArray {
    if (otherArray.count == self.count) {
        for (NSString *string in self) {
            if (![otherArray containsObject:string]) {
                return NO;
            }
        }
        return YES;
    }
    else {
        return NO;
    }
}

@end
