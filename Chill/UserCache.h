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
+(NSString *) isEntry;
+(BOOL) isAuth;
+(BOOL) showGuide;
+(BOOL) isAprooved;
+(void) changeAuth:(BOOL)auth;
+(void) changeAprooved:(BOOL)auth;
+(void) changeGuide:(BOOL)guide;
+(void) setValue:(NSString*)value forKey:(NSString*)key;
@end
