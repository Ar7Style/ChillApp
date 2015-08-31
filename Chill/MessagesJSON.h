//
//  MessagesJSON.h
//  Chill
//
//  Created by Михаил Луцкий on 30.12.14.
//  Copyright (c) 2014 Chill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessagesJSON : NSObject
- (id)initWithJSONDictionary:(NSDictionary *)jsonDictionary;
@property (readonly) NSString *content;
@property (readonly) NSString *date_created;
@property (readonly) NSString *id_from_user;
@property (readonly) NSString *id_user;
@property (readonly) NSString *id_contact;
@property (readonly) NSString *read;
@property (readonly) NSString *type;
@property (readonly) NSString *code;

@end
