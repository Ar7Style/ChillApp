//
//  UserCache.m
//  Chill
//
//  Created by Михаил Луцкий on 22.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import "UserCache.h"

@implementation NSUserDefaults (UserCache)
+(instancetype) NSUserDefaultsString:(NSString*) key {
    return [[[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"] valueForKey:key];
}
+(BOOL) NSUserDefaultsBool:(NSString*) key {
    return [[[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"] boolForKey:key];
}
+(NSString *)userToken {
    return [self NSUserDefaultsString:@"token"];
}
+(NSString *)userID {
    return [self NSUserDefaultsString:@"id_user"];
}
+(NSString *)userLogin {
    return [self NSUserDefaultsString:@"login_user"];
}
+(NSString *)userPicture {
    return [self NSUserDefaultsString:@"Picture"];
}
+(NSString *)userType {
    return [self NSUserDefaultsString:@"Type"];
}
+(BOOL)isAuth {
    return [self NSUserDefaultsBool:@"isAuth"];
}
+(BOOL)isAprooved {
    return [self NSUserDefaultsBool:@"isApproved"];
}
+(BOOL)showGuide {
    return [self NSUserDefaultsBool:@"guide"];
}
+(NSString *)showNews {
    if ([self NSUserDefaultsBool:@"news"]) {
        return @"true";
    }
    else {
        return @"false";
    }
}
+(void)changeAuth:(BOOL)auth {
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    [userCache setBool:auth forKey:@"isAuth"];
    [userCache synchronize];
}
+(void)changeAprooved:(BOOL)auth {
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    [userCache setBool:auth forKey:@"isApproved"];
    [userCache synchronize];
}
+(void)changeGuide:(BOOL)guide {
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    [userCache setBool:guide forKey:@"guide"];
    [userCache synchronize];
}
+(void)setValue:(NSString *)value forKey:(NSString *)key {
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    [userCache setValue:value forKey:key];
    [userCache synchronize];
}
@end