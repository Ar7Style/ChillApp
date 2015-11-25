//
//  IconsIC.m
//  Chill
//
//  Created by Михаил Луцкий on 23.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import "IconsIC.h"
#import "IconRow.h"
#import "UserCache.h"
#import "ButtonIconID.h"
#import <AFNetworking/AFNetworking.h>

@interface IconsIC () {
    NSArray *json;
    NSMutableDictionary *buttonIDs;
}

@end

@implementation IconsIC

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.title = @"";
    [_iconButton setValue:@"" forKey:@""];
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    buttonIDs = [NSMutableDictionary new];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGetMyNotification:)
                                                 name:@"buttonPressed"
                                               object:nil];
    [self loadData];
}

- (void)didGetMyNotification:(NSNotification*)notification {
    NSLog(@"hello %@", [buttonIDs objectForKey:[NSString stringWithFormat:@"%@",[notification object]]]);
}

- (void) loadData {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
    [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    [manager GET:[NSString stringWithFormat:@"http://api.iamchill.co/v2/icons/index/id_user/%@", [NSUserDefaults userID]] parameters:nil success:^(NSURLSessionTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"]) {
            json = [responseObject objectForKey:@"response"];
            [self configureTable];
        }
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) configureTable {
    int num = json.count/3;
    [self.table setNumberOfRows:num withRowType:@"cell"];
    int j = 0;
    int n = 0;
    for (int i= 0; i<json.count;i++) {
        IconRow* theRow = [self.table rowControllerAtIndex:j];
        if (n == 0 ) {
            [theRow.button1 setBackgroundImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[i] valueForKey:@"size80"]]]];
            [buttonIDs setObject:[json[i] valueForKey:@"id"] forKey:[NSString stringWithFormat:@"%@", theRow.button1]];
            
        }
        else if (n == 1) {
            [theRow.button2 setBackgroundImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[i] valueForKey:@"size80"]]]];
            [buttonIDs setObject:[json[i] valueForKey:@"id"] forKey:[NSString stringWithFormat:@"%@", theRow.button2]];
        }
        else if (n == 2) {
            [theRow.button3 setBackgroundImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[i] valueForKey:@"size80"]]]];
            [buttonIDs setObject:[json[i] valueForKey:@"id"] forKey:[NSString stringWithFormat:@"%@", theRow.button3]];
        }
        n++;
        if (!((i+1)%3)){
            j++; n =0;
        }
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



