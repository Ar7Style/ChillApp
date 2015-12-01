//
//  ButtonIconID.m
//  Chill
//
//  Created by Михаил Луцкий on 25.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import "ButtonIconID.h"

@implementation WKInterfaceButton (ButtonIconID)
int iconident;
+(NSString *)iconID {
    return [NSString stringWithFormat:@"%i",iconident];
}
+(void)setIconID:(NSString *)value {
    iconident = [value intValue];
}

@end
