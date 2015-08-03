//
//  UIColor+ChillColors.m
//  Chill
//
//  Created by Виктор Шаманов on 6/22/14.
//  Copyright (c) 2014 Chill. All rights reserved.
//

#import "UIColor+ChillColors.h"

@implementation UIColor (ChillColors)

+ (instancetype)colorWith255Red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

+ (instancetype)colorWith255Gray:(NSInteger)grayScale {
    return [self colorWith255Red:grayScale green:grayScale blue:grayScale];
}

+ (instancetype)chillMintColor {
    return [self colorWith255Red:35 green:197 blue:158];
}

+ (instancetype)chillLightGrayColor {
    return [self colorWith255Gray:246];
}

+ (instancetype)chillDarkGrayColor {
    //return [self colorWith255Gray:210];
    return [UIColor colorWith255Red:161 green:161 blue:161];
}

@end
