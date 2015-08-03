//
//  JSONLoader.m
//  JSONHandler
//
//  Created by Mikhail Loutskiy on 28/10/2013.
//  Copyright (c) 2013 LWTS. All rights reserved.
//

#import "JSONLoader.h"
#import "FriendsJSON.h"
#import "MessagesJSON.h"
#import "SearchJSON.h"
#import "CHLFriendsListViewController.h"
#import "APPROVEDViewController.h"
@implementation JSONLoader

- (NSArray *)locationsFromJSONFile:(NSURL *)url typeJSON:(NSString *)type {
    int method = 0;
    if ([type isEqualToString:@"Friends"]){
        method = 1;
    }
    else if ([type isEqualToString:@"Messages"]){
        method = 2;
    }
    else if ([type isEqualToString:@"Search"]){
        method = 3;
    }
    
   

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:30.0];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"]; [request setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];

    
    NSURLResponse *response;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    NSArray *array = [jsonDictionary objectForKey:@"response"];
    if (![[jsonDictionary objectForKey:@"status"] isEqualToString:@"failed" ]){
    NSLog(@"array %@", array);
    for(NSDictionary *dict in array) {

        switch (method) {
            case 1:{
                FriendsJSON *location = [[FriendsJSON alloc] initWithJSONDictionary:dict];
                [locations addObject:location];
                break;
            }
            case 2:{
                MessagesJSON *location = [[MessagesJSON alloc] initWithJSONDictionary:dict];
                [locations addObject:location];
                break;
            }
            case 3:{
                SearchJSON *location = [[SearchJSON alloc] initWithJSONDictionary:dict];
                [locations addObject:location];
                break;
            }
            default:
                break;
        }
    }}
    
    return locations;
}


@end
