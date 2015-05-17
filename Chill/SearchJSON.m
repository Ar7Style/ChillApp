//
//  SearchJSON.m
//  Chill
//
//  Created by Михаил Луцкий on 30.12.14.
//  Copyright (c) 2014 Victor Shamanov. All rights reserved.
//

#import "SearchJSON.h"

@implementation SearchJSON
- (id)initWithJSONDictionary:(NSDictionary *)jsonDictionary {
    if(self = [self init]) {
        // Assign all properties with keyed values from the dictionary
        _approved       = [jsonDictionary objectForKey:@"approved"];
        _date_reg       = [jsonDictionary objectForKey:@"date_reg"];
        _email          = [jsonDictionary objectForKey:@"email"];
        _id_user        = [jsonDictionary objectForKey:@"id"];
        _login          = [jsonDictionary objectForKey:@"login"];
        _name           = [jsonDictionary objectForKey:@"name"];
    }
    
    return self;
}
@end
