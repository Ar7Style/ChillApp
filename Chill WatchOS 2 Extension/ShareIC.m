//
//  ShareICInterfaceController.m
//  Chill
//
//  Created by Михаил Луцкий on 22.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import "ShareIC.h"
#import "UserCache.h"
#import <AFNetworking/AFNetworking.h>

@interface ShareIC () {
    NSArray *json;
    NSInteger *itemsPicker[60];
}

@end

@implementation ShareIC

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    if (![NSUserDefaults showGuide]) {
        [NSUserDefaults changeGuide:true];
        [self presentControllerWithName:@"HelpIC" context:nil];
    }
    self.title = @"Back";
    NSLog(@"CON %@", context);
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self loadData];
    _pickerItems = [[NSMutableArray alloc] init];
    WKPickerItem *item = [[WKPickerItem alloc] init];;
    [item setTitle:[NSString stringWithFormat:@" "]];
    [_pickerItems insertObject:item atIndex:0];
    for (int i = 0; i < 60; i++) {
        WKPickerItem *item = [[WKPickerItem alloc] init];;
        [item setTitle:[NSString stringWithFormat:@"%i",i+1]];
        [_pickerItems insertObject:item atIndex:i+1];
    }
    [_countValue setItems:self.pickerItems];

}

- (void) loadData {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
    [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    [manager GET:[NSString stringWithFormat:@"http://api.iamchill.co/v2/icons/user/id_user/%@", [NSUserDefaults userID]] parameters:nil success:^(NSURLSessionTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"]) {
            json = [responseObject objectForKey:@"response"];
            [self setIcons];
        }
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) setIcons {
    [_icon1 setBackgroundImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[0] valueForKey:@"size80"]]]];
    [_icon2 setBackgroundImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[1] valueForKey:@"size80"]]]];
    [_icon3 setBackgroundImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[2] valueForKey:@"size80"]]]];
    [_icon4 setBackgroundImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[3] valueForKey:@"size80"]]]];
    [_icon5 setBackgroundImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[4] valueForKey:@"size80"]]]];
    [_icon6 setBackgroundImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[0] valueForKey:@"size80"]]]];
    
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



