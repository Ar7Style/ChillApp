//
//  FriendsJSON.m
//  JSONLoader
//
//  Created by Mikhail Loutskiy on 28/10/2013.
//  Copyright (c) 2013 LWTS. All rights reserved.//

#import "FriendsJSON.h"

@implementation FriendsJSON

// Init the object with information from a dictionary
- (id)initWithJSONDictionary:(NSDictionary *)jsonDictionary {
    if(self = [self init]) {
        // Assign all properties with keyed values from the dictionary
        _approved       = [jsonDictionary objectForKey:@"approved"];
        _date_reg       = [jsonDictionary objectForKey:@"date_reg"];
        _email          = [jsonDictionary objectForKey:@"email"];
        _id_contact     = [jsonDictionary objectForKey:@"id_contact"];
        _id_user        = [jsonDictionary objectForKey:@"id_sender"];
        _login          = [jsonDictionary objectForKey:@"login"];
        _name           = [jsonDictionary objectForKey:@"name"];
        _read           = [jsonDictionary objectForKey:@"read"];
        _type           = [jsonDictionary objectForKey:@"type"];
        _content        = [jsonDictionary objectForKey:@"content"];
    }
    
    return self;
}

@end
