//
//  UserCache.h
//  Chill
//
//  Created by Михаил Луцкий on 22.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (UserCache)

+(NSString *) userToken;
+(NSString *) userID;
+(NSString *) userLogin;
+(NSString *) userPicture;
+(NSString *) userType;
+(BOOL) isAuth;
+(BOOL) isAprooved;
+(void) changeAuth:(BOOL)auth;
+(void) changeAprooved:(BOOL)auth;
+(void) setValue:(NSString*)value forKey:(NSString*)key;
@end
