//
//  ANHelperFunctions.h
//
//  Created by Oksana Kovalchuk on 6/7/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANDefines.h"

/**
 *  Execute block on main thread
 *
 *  @param ANCodeBlock block for execution
 */
void ANDispatchBlockToMainQueue(ANCodeBlock);


/**
 *  Creates new block instance with execution on main thread
 */
ANCodeBlock ANMainQueueBlockFromCompletion(ANCodeBlock);


/**
 *  Execute block on main thread
 *
 *  @param ANCompletionBlock block to execute
 *
 *  @return ANCompletionBlock returns new block with adding dispatch_main_queue
 */
ANCompletionBlock ANMainQueueCompletionFromCompletion(ANCompletionBlock);

/**
 *  Execute block on block on background thread
 *
 *  @param ANCompletionBlock block to execute
 *  @param NSError*          instance for handling any blocks errors
 */
void ANDispatchCompletionBlockToMainQueue(ANCompletionBlock, NSError *);

/**
 *  Executes the block after specified time
 *
 *  @param time Time to after
 *  @param block Block to execute
 */
void ANDispatchBlockAfter(CGFloat, ANCodeBlock);

void ANDispatchBlockToBackgroundQueue(ANCodeBlock);

#pragma Objects

BOOL ANIsEmpty(id);
BOOL ANIsEmptyStringByTrimmingWhitespaces(NSString*);


