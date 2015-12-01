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
    NSString *contactID;
<<<<<<< HEAD
=======
    NSString *valueSelected;
>>>>>>> c6b5dca4d14148f199961f370481cf32455f6519
}

@end

@implementation ShareIC
@synthesize myTimer;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    if (![NSUserDefaults showGuide]) {
        [NSUserDefaults changeGuide:true];
        [self presentControllerWithName:@"HelpIC" context:nil];
    }
    self.title = @"Back";
    contactID = context;
<<<<<<< HEAD

=======
    valueSelected = @"";
>>>>>>> c6b5dca4d14148f199961f370481cf32455f6519
    NSLog(@"CON %@", context);
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [_group1 setHidden:YES];
    [_group2 setHidden:YES];
    [_group3 setHidden:YES];
    [_statusText setHidden:NO];
    [_statusIMG setHidden:YES];
    [_statusText setText:@"Loading..."];
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
            [_group1 setHidden:NO];
            [_group2 setHidden:NO];
            [_group3 setHidden:NO];
            [_statusText setHidden:YES];
        }
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [self popToRootController];
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

- (void) sendMessage:(NSString*)idButton {
<<<<<<< HEAD
    NSDictionary *parametrs = @{@"id_user":[NSUserDefaults userID], @"id_contact":contactID, @"content":[idButton lowercaseString], @"type":@"icon"};
=======
    NSDictionary *parametrs = @{@"id_user":[NSUserDefaults userID], @"id_contact":contactID, @"content":[idButton lowercaseString], @"type":@"icon", @"text":valueSelected};
>>>>>>> c6b5dca4d14148f199961f370481cf32455f6519
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
    [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    [manager POST:[NSString stringWithFormat:@"http://api.iamchill.co/v2/messages/index/"] parameters:parametrs success:^(NSURLSessionTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"]) {
            [_group1 setHidden:YES];
            [_group2 setHidden:YES];
            [_group3 setHidden:YES];
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
        [_group1 setHidden:YES];
        [_group2 setHidden:YES];
        [_group3 setHidden:YES];
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
- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)b1 {
    [self sendMessage:[json[0] valueForKey:@"name"]];
}

- (IBAction)b2 {
    [self sendMessage:[json[1] valueForKey:@"name"]];
}

- (IBAction)b3 {
    [self sendMessage:[json[2] valueForKey:@"name"]];
}

- (IBAction)b4 {
    [self sendMessage:[json[3] valueForKey:@"name"]];
}

- (IBAction)b5 {
    [self sendMessage:[json[4] valueForKey:@"name"]];
}

- (IBAction)b6 {
    [self sendMessage:[json[5] valueForKey:@"name"]];
}
<<<<<<< HEAD
=======

- (IBAction)didChangeValue:(NSInteger)value {
    if (value != 0)
        valueSelected = [NSString stringWithFormat:@"%i", value];
    else
        valueSelected = @"";
}

- (IBAction)sendLocation {
    [self startLocationReporting];
}
- (void)startLocationReporting {
    NSLog(@"startLocation");
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;//or whatever class you have for managing location
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [_locationManager requestAlwaysAuthorization];
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager requestLocation];
    //    [_locationManager startMonitoringSignificantLocationChanges];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
        NSLog(@"locationManager %@", locations);
    NSDictionary *parametrs = @{@"id_user":[NSUserDefaults userID], @"id_contact":contactID, @"content":[NSString stringWithFormat:@"%f %f", locations.lastObject.coordinate.latitude, locations.lastObject.coordinate.longitude], @"type":@"location"};
    AFHTTPSessionManager *sManager = [AFHTTPSessionManager manager];
    sManager.responseSerializer = [AFJSONResponseSerializer serializer];
    sManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [sManager.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
    [sManager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    [sManager POST:[NSString stringWithFormat:@"http://api.iamchill.co/v2/messages/index/"] parameters:parametrs success:^(NSURLSessionTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"]) {
            [_group1 setHidden:YES];
            [_group2 setHidden:YES];
            [_group3 setHidden:YES];
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
        [_group1 setHidden:YES];
        [_group2 setHidden:YES];
        [_group3 setHidden:YES];
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
    [manager stopUpdatingLocation];

}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"fail");
}
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//    NSLog(@"locationManager");
//    latUser = newLocation.coordinate.latitude;
//    lonUser= newLocation.coordinate.longitude;
//    NSLog(@"coord %f %f", latUser, lonUser);
//    //    [_locationManager stopUpdatingLocation];
//}
>>>>>>> c6b5dca4d14148f199961f370481cf32455f6519
@end



