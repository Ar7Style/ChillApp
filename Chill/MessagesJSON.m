//
//  MessagesJSON.m
//  Chill
//
//  Created by Михаил Луцкий on 30.12.14.
//  Copyright (c) 2014 Chill. All rights reserved.
//

#import "MessagesJSON.h"

@implementation MessagesJSON
- (id)initWithJSONDictionary:(NSDictionary *)jsonDictionary {
    if(self = [self init]) {
        // Assign all properties with keyed values from the dictionary
        _content        = [jsonDictionary objectForKey:@"content"];
        _date_created   = [jsonDictionary objectForKey:@"date_created"];
        _id_from_user   = [jsonDictionary objectForKey:@"id_from_user"];
        _id_user        = [jsonDictionary objectForKey:@"id_user"];
        _read           = [jsonDictionary objectForKey:@"read"];
        _type           = [jsonDictionary objectForKey:@"type"];
        _code           = [jsonDictionary objectForKey:@"code"];
        _text           = [jsonDictionary objectForKey:@"text"];
    }
    
    return self;
}

@end
