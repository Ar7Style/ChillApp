//
//  SearchJSON.h
//  Chill
//
//  Created by Михаил Луцкий on 30.12.14.
//  Copyright (c) 2014 Victor Shamanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchJSON : NSObject
- (id)initWithJSONDictionary:(NSDictionary *)jsonDictionary;
@property (readonly) NSString *approved;
@property (readonly) NSString *date_reg;
@property (readonly) NSString *email;
//@property (readonly) NSString *hash;
@property (readonly) NSString *id_user;
@property (readonly) NSString *key;
@property (readonly) NSString *login;
@property (readonly) NSString *name;

@end
