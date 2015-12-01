//
//  ButtonIconID.h
//  Chill
//
//  Created by Михаил Луцкий on 25.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import <WatchKit/WatchKit.h>

@interface WKInterfaceButton (ButtonIconID)

+(NSString *) iconID;
+(void) setIconID:(NSString*)value;

@end
