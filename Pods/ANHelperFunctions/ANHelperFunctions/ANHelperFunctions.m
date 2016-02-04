//
//  ANHelperFunctions.m
//
//  Created by Oksana Kovalchuk on 6/7/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANHelperFunctions.h"

void ANDispatchCompletionBlockToMainQueue(ANCompletionBlock block, NSError *error)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) block(error);
    });
}

ANCompletionBlock ANMainQueueCompletionFromCompletion(ANCompletionBlock block)
{
    if (!block) return NULL;
    return ^(NSError *error) {
        ANDispatchBlockToMainQueue(^{
           block(error);
        });
    };
}

void ANDispatchBlockToMainQueue(ANCodeBlock block)
{
    if ([NSThread isMainThread])
    {
        if (block) block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block();
        });
    }
}

ANCodeBlock ANMainQueueBlockFromCompletion(ANCodeBlock block)
{
    if (!block) return NULL;
    return ^{
        
        ANDispatchBlockToMainQueue(^{
            block();
        });
    };
}

void ANDispatchBlockAfter(CGFloat time, ANCodeBlock block)
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

void ANDispatchBlockToBackgroundQueue(ANCodeBlock block)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (block) block();
    });
}


#pragma mark - Objects

BOOL ANIsEmpty(id thing)
{
    return ((thing == nil) ||
            ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0) ||
            ([thing respondsToSelector:@selector(count)] && [(NSArray *)thing count] == 0));
}

BOOL ANIsEmptyStringByTrimmingWhitespaces(NSString* string)
{
    if (string)
    {
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    return ((string == nil) ||
            ([string respondsToSelector:@selector(length)] && [string length] == 0));
}
