//
//  CHLLocationShareManager.h
//  Chill
//
//  Created by Ivan Grachev on 2/23/16.
//  Copyright © 2016 Chlil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHLLocationShareManager : NSObject

+ (id)sharedManager;
- (void)shareLocationWithUser:(NSInteger)userID;

@end
