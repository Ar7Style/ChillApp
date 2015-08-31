//
//  FriendsJSON.h
//  JSONLoader
//
//  Created by Mikhail Loutskiy on 28/10/2013.
//  Copyright (c) 2013 LWTS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendsJSON : NSObject

- (id)initWithJSONDictionary:(NSDictionary *)jsonDictionary;

@property (readonly) NSString *approved;
@property (readonly) NSString *date_reg;
@property (readonly) NSString *email;
//@property (readonly) NSString *hash;
@property (readonly) NSString *id_contact;
@property (readonly) NSString *id_user;
@property (readonly) NSString *key;
@property (readonly) NSString *login;
@property (readonly) NSString *name;
@property (readonly) NSString *twitter_name;

@property (readonly) NSString *read;
@property (readonly) NSString *type;
@property (readonly) NSString *content;

@end
