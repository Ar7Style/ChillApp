//
//  ContactsIC.m
//  Chill
//
//  Created by Михаил Луцкий on 22.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import "ContactsIC.h"
#import "ContactRow.h"
#import "UserCache.h"
#import <AFNetworking/AFNetworking.h>
@interface ContactsIC () {
    NSArray *json;
}

@end

@implementation ContactsIC

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    NSLog(@"Open ContactsIC");
    // Configure interface objects here.
}

- (void) loadData {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
    [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    [manager GET:[NSString stringWithFormat:@"http://api.iamchill.co/v2/contacts/index/id_user/%@", [NSUserDefaults userID]] parameters:nil success:^(NSURLSessionTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"]) {
            json = [responseObject objectForKey:@"response"];
            [self configureTable];
        }
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self loadData];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    [self presentControllerWithNames:@[@"ShareIC", @"IconsIC"] contexts:@[@"12"]];
}

- (void)configureTable {
    [self.table setNumberOfRows:[json count] withRowType:@"cell"];
    for (NSInteger i = 0; i < self.table.numberOfRows; i++) {
        ContactRow* theRow = [self.table rowControllerAtIndex:i];
        NSArray *contactData = json[i];
        [theRow.userName setText:[contactData valueForKey:@"login"]];
    }
}

@end



