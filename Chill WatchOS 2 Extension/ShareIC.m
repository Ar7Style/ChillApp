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
#import "NSString+MD5.h"

#import "FlurryWatch.h"

@interface ShareIC () {
    NSArray *json;
    NSInteger *itemsPicker[60];
    NSString *contactID;
    NSString *valueSelected;
}

@property(nonatomic, strong) NSMutableArray *icons;
@property(nonatomic, strong) NSMutableArray *iconNames;

@end

@implementation ShareIC
@synthesize myTimer;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.icons = [[NSMutableArray alloc] init];
    self.iconNames = [[NSMutableArray alloc] init];
    if (![NSUserDefaults showGuide]) {
        [NSUserDefaults changeGuide:true];
        [self presentControllerWithName:@"Tutorial" context:nil];
    }
    self.title = @"Back";
    contactID = context;
    valueSelected = @"";
    [_group1 setHidden:YES];
    [_group2 setHidden:YES];
    [_group3 setHidden:YES];
    [_statusText setHidden:NO];
    [_statusIMG setHidden:YES];
    [_statusText setText:@"Loading..."];
    [self loadData];
    NSLog(@"CON %@", context);
    
    [FlurryWatch logWatchEvent:@"The ShareIC has been presented"];

}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];

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
    [self.countValue focus];

}

- (void) loadData {
    if ([self fetchAllIconsFromStorage]) {
        [self setIcons];
        [_group1 setHidden:NO];
        [_group2 setHidden:NO];
        [_group3 setHidden:NO];
        [_statusText setHidden:YES];
    }
    else {
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

- (BOOL)fetchAllIconsFromStorage {
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    NSArray *favorites = [userCache objectForKey:@"FavoritesArray"];
    if (favorites != nil) {
        NSMutableArray *images = [[NSMutableArray alloc] init];
        for (NSString *name in favorites) {
            UIImage *image = [self fetchImageWithName:name];
            if (image != nil) {
                [images addObject:image];
            }
        }
        if (images.count == favorites.count) {
            self.icons = images;
            self.iconNames = [favorites mutableCopy];
            return YES;
        }
    }
    return NO;
}

- (void)setIcons {
    NSArray *buttonsArray = @[self.icon1, self.icon2, self.icon3, self.icon4, self.icon5, self.icon6];
    if (self.icons != nil && self.icons.count != 0) {
        for (int j = 0; j < self.icons.count && j < buttonsArray.count; j++) {
            [buttonsArray[j] setBackgroundImage:self.icons[j]];
        }
        return;
    }
    int i = 0;
    [self.icons removeAllObjects];
    [self.iconNames removeAllObjects];
    for (WKInterfaceButton *button in buttonsArray) {
        if (i >= json.count) {
            return;
        }
        NSURL *imageURL = [NSURL URLWithString:[json[i] valueForKey:@"size80"]];
        NSString *imageName = [NSString stringWithFormat:@"%@",[json[i] valueForKey:@"name"]];
        [self.iconNames addObject:imageName];
        UIImage *fetchedImage = [self fetchImageWithName:imageName];
        if (fetchedImage != nil) {
            [button setBackgroundImage:fetchedImage];
        }
        else {
            [[[NSURLSession sharedSession] dataTaskWithURL:imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                [self saveImageData:data withName:imageName];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [button setBackgroundImageData:data];
                });
            }] resume];
        }
        i++;
    }
}

- (void) sendMessage:(NSString*)idButton {
    [_group1 setHidden:YES];
    [_group2 setHidden:YES];
    [_group3 setHidden:YES];
    [_statusIMG setHidden:NO];
    [_statusText setHidden:NO];
    [_statusIMG setImageNamed:@"Activity"];
    [_statusIMG startAnimating];
    [_statusText setText:@"Sending..."];
    
    
    NSDictionary *parametrs = @{@"id_user":[NSUserDefaults userID], @"id_contact":contactID, @"content":[idButton lowercaseString], @"type":@"icon", @"text":valueSelected};
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
- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)b1 {
    [self sendMessage:self.iconNames[0]];
}

- (IBAction)b2 {
    [self sendMessage:self.iconNames[1]];
}

- (IBAction)b3 {
    [self sendMessage:self.iconNames[2]];
}

- (IBAction)b4 {
    [self sendMessage:self.iconNames[3]];
}

- (IBAction)b5 {
    [self sendMessage:self.iconNames[4]];
}

- (IBAction)b6 {
    [self sendMessage:self.iconNames[5]];
}

- (IBAction)didChangeValue:(NSInteger)value {
    if (value != 0)
        valueSelected = [NSString stringWithFormat:@"%i", value];
    else
        valueSelected = @"";
}

- (IBAction)sendLocation {
    [_group1 setHidden:YES];
    [_group2 setHidden:YES];
    [_group3 setHidden:YES];
    [_statusIMG setHidden:NO];
    [_statusText setHidden:NO];
    [_statusIMG setImageNamed:@"Activity"];
    [_statusIMG startAnimating];
    [_statusText setText:@"Sending..."];
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
@end



