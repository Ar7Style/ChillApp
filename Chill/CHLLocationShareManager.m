//
//  CHLLocationShareManager.m
//  Chill
//
//  Created by Ivan Grachev on 2/23/16.
//  Copyright © 2016 Chlil. All rights reserved.
//

#import "CHLLocationShareManager.h"
#import <CoreLocation/CoreLocation.h>

@interface CHLLocationShareManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic) NSInteger userIDTo;
@property (nonatomic) BOOL didSendLocation;

@end

NSMutableData *mutData;

@implementation CHLLocationShareManager

+ (id)sharedManager {
    static CHLLocationShareManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void)shareLocationWithUser:(NSInteger)userID {
    self.userIDTo = userID;
    self.didSendLocation = NO;
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager requestLocation];
}

- (NSString*) getDateTime {
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    [currDate timeIntervalSince1970];
    [dateFormatter setDateFormat:@"dd.MM.YY HH:mm:ss"];
    NSString* dateString =[NSString stringWithFormat:@"%lld",milliseconds];
    NSLog(@"%@", dateString);
    return dateString;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (!self.didSendLocation && locations.count != 0) {
        self.didSendLocation = YES;
        CLLocation *currentLocation = [locations lastObject];
        NSMutableURLRequest *request =
        [[NSMutableURLRequest alloc] initWithURL:
        [NSURL URLWithString:@"http://api.iamchill.co/v2/messages/index/"]];
        [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
        [request setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
        [request setHTTPMethod:@"POST"];
        NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
        NSString *postString = [NSString stringWithFormat:@"id_contact=%ld&id_user=%@&content=%@ %@&type=location&date=%@",(long)self.userIDTo,[userCache valueForKey:@"id_user"],[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude], [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude], [self getDateTime]];
        [request setHTTPBody:[postString
                              dataUsingEncoding:NSUTF8StringEncoding]];
        [_locationManager stopUpdatingLocation];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (connection) {
            mutData = [NSMutableData data];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (!self.didSendLocation) {
        self.didSendLocation = YES;
        CLLocation *currentLocation = newLocation;
        NSMutableURLRequest *request =
        [[NSMutableURLRequest alloc] initWithURL:
         [NSURL URLWithString:@"http://api.iamchill.co/v2/messages/index/"]];
        [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
        [request setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
        [request setHTTPMethod:@"POST"];
        NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
        NSString *postString = [NSString stringWithFormat:@"id_contact=%ld&id_user=%@&content=%@ %@&type=location&date=%@",(long)self.userIDTo,[userCache valueForKey:@"id_user"],[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude], [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude], [self getDateTime]];
        [request setHTTPBody:[postString
                              dataUsingEncoding:NSUTF8StringEncoding]];
        [_locationManager stopUpdatingLocation];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (connection) {
            mutData = [NSMutableData data];
        }
    }
}

@end
