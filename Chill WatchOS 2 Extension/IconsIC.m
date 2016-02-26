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
#import "FTWCache.h"
#import "NSString+MD5.h"

@interface IconsIC () {
    NSArray *json;
    NSMutableDictionary *buttonIDs;
    NSString *contactID;
}

@end

@implementation IconsIC
@synthesize myTimer;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.title = @"";
    contactID = context;

    [_iconButton setValue:@"" forKey:@""];
    NSLog(@"cID %@", context);
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [_statusIMG setHidden:YES];
    [_statusText setHidden:YES];
    buttonIDs = [NSMutableDictionary new];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGetMyNotification:)
                                                 name:@"buttonPressed"
                                               object:nil];
    [self loadData];
}

- (void)didGetMyNotification:(NSNotification*)notification {
    NSLog(@"hello %@", [buttonIDs objectForKey:[NSString stringWithFormat:@"%@",[notification object]]]);

    NSDictionary *parametrs = @{@"id_user":[NSUserDefaults userID], @"id_contact":contactID, @"content":[buttonIDs objectForKey:[NSString stringWithFormat:@"%@",[notification object]]], @"type":@"icon"};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
    [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    [manager POST:[NSString stringWithFormat:@"http://api.iamchill.co/v2/messages/index/"] parameters:parametrs success:^(NSURLSessionTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"]) {
            [_table setHidden:YES];
            [_textMore setHidden:YES];
            [_statusIMG setHidden:NO];
            [_statusText setHidden:NO];
            [_statusText setText:@"Done"];
            [_statusIMG setImageNamed:@"confirm"];
            self.title = @"";
            self.myTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                            target:self
                                                          selector:@selector(tick)
                                                          userInfo:nil
                                                           repeats:YES];
            
            //            [self popController];
        }
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [_table setHidden:YES];
        [_textMore setHidden:YES];
        [_statusIMG setHidden:NO];
        [_statusText setHidden:NO];
        [_statusText setText:@"Failed"];
        [_statusIMG setImageNamed:@"decline"];
        self.title = @"";
        self.myTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                        target:self
                                                      selector:@selector(tick)
                                                      userInfo:nil
                                                       repeats:YES];
        NSLog(@"Error: %@", error);
    }];

}
- (void)tick {
    if ([myTimer isValid]) {
        
        [myTimer invalidate];
        NSArray *array1=[[NSArray alloc] initWithObjects:@"ContactsIC", nil];
        [WKInterfaceController reloadRootControllersWithNames:array1 contexts:nil];
    }
}
- (void) loadData {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
    [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    [manager GET:[NSString stringWithFormat:@"http://api.iamchill.co/v3/icons/index/id_user/%@/name_pack/main", [NSUserDefaults userID]] parameters:nil success:^(NSURLSessionTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"]) {
            json = [responseObject objectForKey:@"response"];
            [self configureTable];
        }
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
//- (void) sendMessage:(NSString*)idButton {
//    NSDictionary *parametrs = @{@"id_user":[NSUserDefaults userID], @"id_contact":contactID, @"content":[idButton lowercaseString], @"type":@"icon"};
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    [manager.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
//    [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
//    [manager POST:[NSString stringWithFormat:@"http://api.iamchill.co/v2/messages/index/"] parameters:parametrs success:^(NSURLSessionTask *task, id responseObject) {
//        if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"]) {
//            [_group1 setHidden:YES];
//            [_group2 setHidden:YES];
//            [_group3 setHidden:YES];
//            [_statusIMG setHidden:NO];
//            [_statusText setHidden:NO];
//            [_statusText setText:@"Done"];
//            [_statusIMG setImageNamed:@"confirm"];
//            self.title = @"";
//            self.myTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
//                                                            target:self
//                                                          selector:@selector(tick)
//                                                          userInfo:nil
//                                                           repeats:YES];
//            
//            //            [self popController];
//        }
//        NSLog(@"JSON: %@", responseObject);
//    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        [_group1 setHidden:YES];
//        [_group2 setHidden:YES];
//        [_group3 setHidden:YES];
//        [_statusIMG setHidden:NO];
//        [_statusText setHidden:NO];
//        [_statusText setText:@"Failed"];
//        [_statusIMG setImageNamed:@"decline"];
//        self.title = @"";
//        self.myTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
//                                                        target:self
//                                                      selector:@selector(tick)
//                                                      userInfo:nil
//                                                       repeats:YES];
//        NSLog(@"Error: %@", error);
//    }];
//}

- (void) configureTable {
    int num = json.count/3;
    [self.table setNumberOfRows:num withRowType:@"cell"];
    int j = 0;
    int n = 0;
    for (int i= 0; i<json.count;i++) {
        IconRow* theRow = [self.table rowControllerAtIndex:j];
        if (n == 0 ) {
            NSURL *imageURL = [NSURL URLWithString:[json[i] valueForKey:@"size80"]];
            NSString *key = [[json[i] valueForKey:@"size80"] MD5Hash];
            NSData *data = [FTWCache objectForKey:key];
            if (data) {
                [theRow.button1 setBackgroundImageData:data];
            }
            else {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(queue, ^{
                    NSData *data = [NSData dataWithContentsOfURL:imageURL];
                    [FTWCache setObject:data forKey:key];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [theRow.button1 setBackgroundImageData:data];
                    });
                });
                
            }
            
//            [theRow.button1 setBackgroundImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[json[i] valueForKey:@"size80"]]]];
            [buttonIDs setObject:[json[i] valueForKey:@"name"] forKey:[NSString stringWithFormat:@"%@", theRow.button1]];
            
        }
        else if (n == 1) {
            NSURL *imageURL = [NSURL URLWithString:[json[i] valueForKey:@"size80"]];
            NSString *key = [[json[i] valueForKey:@"size80"] MD5Hash];
            NSData *data = [FTWCache objectForKey:key];
            if (data) {
                [theRow.button2 setBackgroundImageData:data];
            }
            else {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(queue, ^{
                    NSData *data = [NSData dataWithContentsOfURL:imageURL];
                    [FTWCache setObject:data forKey:key];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [theRow.button2 setBackgroundImageData:data];
                    });
                });
                
            }
            
            [buttonIDs setObject:[json[i] valueForKey:@"name"] forKey:[NSString stringWithFormat:@"%@", theRow.button2]];
        }
        else if (n == 2) {
            NSURL *imageURL = [NSURL URLWithString:[json[i] valueForKey:@"size80"]];
            NSString *key = [[json[i] valueForKey:@"size80"] MD5Hash];
            NSData *data = [FTWCache objectForKey:key];
            if (data) {
                [theRow.button3 setBackgroundImageData:data];
            }
            else {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(queue, ^{
                    NSData *data = [NSData dataWithContentsOfURL:imageURL];
                    [FTWCache setObject:data forKey:key];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [theRow.button3 setBackgroundImageData:data];
                    });
                });
                
            }
            
            [buttonIDs setObject:[json[i] valueForKey:@"name"] forKey:[NSString stringWithFormat:@"%@", theRow.button3]];
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



