# ANHelperFunctions

A set of small useful helpers for iOS development

Feel free to fork, update and make a pull-requests.

# Defines

#### SYSTEM_VERSION
Float sytem version number. Example: `7.1.1`, `8.1`, `8.1.1`

#### IS_IPHONE_5
Returns `YES` if running on iPhone 5

#### IS_IPHONE_6
Returns `YES` if running on iPhone 6

#### IS_IPHONE_6_PLUS
Returns `YES` if running on iPhone 6 Plus

#### IS_IPHONE_5_OR_HIGHER
Returns `YES` if running on iPhone 5 or more modern device

#### IS_RETINA
Returns `YES` if running on device with Retina Display

#### IOS7
Returns `YES` if running on iOS 7 (7.x.x)

#### IOS8
Returns `YES` if running on iOS 8 (8.x.x)

#### IOS7_OR_HIGHER
Returns `YES` if running on iOS 7 or later

# Types

#### ANCodeBlock
`typedef void (^ANCodeBlock)(void);`

#### ANCompletionBlock
`typedef void (^ANCompletionBlock)(NSError *error);`

#### ANValidationBlock
`typedef BOOL(^ANValidationBlock)();`

# Methods

#### ANDispatchBlockToMainQueue(ANCodeBlock)

Execute block on main thread

**@param** ANCodeBlock block for execution
  
#### ANMainQueueBlockFromCompletion(ANCodeBlock)

Creates new block instance with execution on main thread

#### ANMainQueueCompletionFromCompletion(ANCompletionBlock)

Execute block on main thread

**@param** ANCompletionBlock block to execute

**@return** ANCompletionBlock returns new block with adding dispatch_main_queue

#### ANDispatchCompletionBlockToMainQueue(ANCompletionBlock, NSError *)

Execute block on block on background thread

**@param** ANCompletionBlock block to execute

**@param** NSError*          instance for handling any blocks errors

#### ANDispatchBlockAfter(CGFloat time, ANCodeBlock block)

Executes the block after specified time

**@param** time Time to after

**@param** block Block to execute
