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
}

- (void)willActivate {
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
    [_table setHidden:YES];
    [_textMore setHidden:YES];
    [_statusIMG setHidden:NO];
    [_statusText setHidden:NO];
    [_statusIMG setImageNamed:@"Activity"];
    [_statusIMG startAnimating];
    [_statusText setText:@"Sending..."];

    NSDictionary *parametrs = @{@"id_user":[NSUserDefaults userID], @"id_contact":contactID, @"content":[buttonIDs objectForKey:[NSString stringWithFormat:@"%@",[notification object]]], @"type":@"icon"};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
    [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    [manager POST:@"http://api.iamchill.co/v2/notifications/message" parameters:parametrs success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"Success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Fail");
    }];
    [manager POST:[NSString stringWithFormat:@"http://api.iamchill.co/v2/messages/index/"] parameters:parametrs success:^(NSURLSessionTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"]) {
            [_statusText setText:@"Done"];
            [_statusIMG setImageNamed:@"confirm"];
            [_statusIMG stopAnimating];
            self.title = @"";
            self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                            target:self
                                                          selector:@selector(tick)
                                                          userInfo:nil
                                                           repeats:YES];
            
            //            [self popController];
        }
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [_statusText setText:@"Failed"];
        [_statusIMG setImageNamed:@"decline"];
        [_statusIMG stopAnimating];
        self.title = @"";
        self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
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

- (void)saveImageData:(NSData *)imageData withName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:name];
    [imageData writeToFile:savedImagePath atomically:NO];
}

- (UIImage *)fetchImageWithName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:name];
    NSData *pngData = [NSData dataWithContentsOfFile:savedImagePath];
    return [UIImage imageWithData:pngData];
}

- (void) configureTable {
    int num = json.count/3;
    [self.table setNumberOfRows:num withRowType:@"cell"];
    int j = 0;
    int n = 0;
    for (int i= 0; i<json.count;i++) {
        IconRow* theRow = [self.table rowControllerAtIndex:j];
        if (n == 0 ) {
            NSURL *imageURL = [NSURL URLWithString:[json[i] valueForKey:@"size80"]];
            NSString *imageName = [json[i] valueForKey:@"name"];
            UIImage *image = [self fetchImageWithName:imageName];
            if (image != nil) {
                [theRow.button1 setBackgroundImage:image];
            }
            else {
                [[[NSURLSession sharedSession] dataTaskWithURL:imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    [self saveImageData:data withName:imageName];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [theRow.button1 setBackgroundImageData:data];
                    });
                }] resume];
            }
            
            [buttonIDs setObject:[json[i] valueForKey:@"name"] forKey:[NSString stringWithFormat:@"%@", theRow.button1]];
            
        }
        else if (n == 1) {
            NSURL *imageURL = [NSURL URLWithString:[json[i] valueForKey:@"size80"]];
            NSString *imageName = [json[i] valueForKey:@"name"];
            UIImage *image = [self fetchImageWithName:imageName];
            if (image != nil) {
                [theRow.button2 setBackgroundImage:image];
            }
            else {
                [[[NSURLSession sharedSession] dataTaskWithURL:imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    [self saveImageData:data withName:imageName];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [theRow.button2 setBackgroundImageData:data];
                    });
                }] resume];
                
            }
            
            [buttonIDs setObject:[json[i] valueForKey:@"name"] forKey:[NSString stringWithFormat:@"%@", theRow.button2]];
        }
        else if (n == 2) {
            NSURL *imageURL = [NSURL URLWithString:[json[i] valueForKey:@"size80"]];
            NSString *imageName = [json[i] valueForKey:@"name"];
            UIImage *image = [self fetchImageWithName:imageName];
            if (image != nil) {
                [theRow.button3 setBackgroundImage:image];
            }
            else {
                [[[NSURLSession sharedSession] dataTaskWithURL:imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    [self saveImageData:data withName:imageName];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [theRow.button3 setBackgroundImageData:data];
                    });
                }] resume];
                
            }
            
            [buttonIDs setObject:[json[i] valueForKey:@"name"] forKey:[NSString stringWithFormat:@"%@", theRow.button3]];
        }
        n++;
        if (!((i+1)%3)){
            j++; n =0;
        }
    }
}

@end



