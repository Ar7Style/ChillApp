//
//  MessInterfaceController.m
//  Chill
//
//  Created by Михаил Луцкий on 01.04.15.
//  Copyright (c) 2015 Chill. All rights reserved.
//

#import "MessInterfaceController.h"
#import "CHLTableMessWK.h"
#import "JSONLoader.h"
#import "MessagesJSON.h"
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"

@interface MessInterfaceController()<CLLocationManagerDelegate>{
    int friendid;
    Reachability *internetReachableFoo;

}

@end
NSMutableData *mutData;


@implementation MessInterfaceController{
    NSArray *_locations;
    CLLocationManager *locationManager;
}
- (BOOL)connected
{
    return [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable;
}
- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    friendid = [context intValue];
    [self loadJSON];
    NSLog(@"context %@", context);
    // Configure interface objects here.
}
- (void)configureTableWithData {
    
    [self.table setNumberOfRows:[_locations count] withRowType:@"cell"];
    for (NSInteger i = 0; i < self.table.numberOfRows; i++) {
        CHLTableMessWK* theRow = [self.table rowControllerAtIndex:i];
        MessagesJSON *location = [_locations objectAtIndex:i];
        //MyDataObject* dataObj = [dataObjects objectAtIndex:i];
        //theRow.title = @"hhhh";
        NSLog(@"img %@", location.content);
        
        //говнокод
        
        if ([location.type isEqualToString:@"icon"]){
        if ([location.content isEqualToString:@"logo"]){
            [theRow.image3 setImageNamed:@"Rectangle_16__Chill_logo_green_3@2x"];
        }
        else if ([location.content isEqualToString:@"clock"]){
            [theRow.image3 setImageNamed:@"Rectangle_20__clock96_5@2x"];

        }
        else if ([location.content isEqualToString:@"coffee"]){
            [theRow.image3 setImageNamed:@"Rectangle_18__soda7_5@2x"];

        }
        else if ([location.content isEqualToString:@"beer"]){
            [theRow.image3 setImageNamed:@"Rectangle_13__drink24_4@2x"];
            
        }
        else if ([location.content isEqualToString:@"rocket"]){
            [theRow.image3 setImageNamed:@"Rectangle_19__rocket61_5@2x"];
            
        }
        else if ([location.content isEqualToString:@"stamp"]){
            [theRow.image3 setImageNamed:@"Rectangle_21__blank17_4@2x"];
            
        }
            
            
        //additional icons
            
        else if ([location.content isEqualToString:@"trophy"]){
            [theRow.image3 setImageNamed: @"Rectangle_received_trophy@2x.png"];
            
        }
        else if ([location.content isEqualToString:@"gym"]){
            [theRow.image3 setImageNamed:@"Rectangle_received_gym@2x"];
            
        }
        else if ([location.content isEqualToString:@"flag"]){
            [theRow.image3 setImageNamed:@"Rectangle_received_flag@2x"];
            
        }
        else if ([location.content isEqualToString:@"telephone"]){
            [theRow.image3 setImageNamed:@"Rectangle_received_telephone@2x"];
            
        }
        else if ([location.content isEqualToString:@"book"]){
            [theRow.image3 setImageNamed:@"Rectangle_received_book@2x"];
            
        }
        else if ([location.content isEqualToString:@"waves"]){
            [theRow.image3 setImageNamed:@"Rectangle_received_waves@2x"];
            
        }
            
            
        }
        else if ([location.type isEqualToString:@"location"]){
            NSString *aString = location.content;
            NSArray *arrayLOC = [aString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            arrayLOC = [arrayLOC filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
            
            NSURL *staticMapImageURL = [self urlOfStaticMapFromLatitude:[arrayLOC[0] doubleValue] longitude:[arrayLOC[1] doubleValue]];
            NSLog(@"loc %@", staticMapImageURL);
            [theRow.image3 setImageData:[NSData dataWithContentsOfURL:staticMapImageURL]];
        }
        else {
            [theRow.image3 setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:location.content]]]];

        }
        
        //[theRow.rowIcon setImage:dataObj.image];
    }
}
- (NSURL *)urlOfStaticMapFromLatitude:(CGFloat)latitude1 longitude:(CGFloat)longitude1 {
    
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=16&size=%0dx%0d&scale=2&sensor=true&markers=icon:http://lwts.ru/marker.png|%f,%f", latitude1, longitude1,272,300, latitude1, longitude1];
    return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}
- (void) loadJSON {
    
    if([self connected]){

    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
            _locations = [[[JSONLoader alloc] init] locationsFromJSONFile:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://api.iamchill.co/v1/messages/index/id_user/%@/id_contact/%i", [userCache valueForKey:@"id_user"], friendid]] typeJSON:@"Messages"];
            [self configureTableWithData];
    });
    }
}
- (void)willActivate {
    locationManager = [[CLLocationManager alloc] init];
    if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [locationManager requestWhenInUseAuthorization];
    }

    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)shareBut {
    [self pushControllerWithName:@"share" context:[NSString stringWithFormat:@"%i",friendid]];
    //[self presentControllerWithName:@"share" context:[NSString stringWithFormat:@"%i",friendid]];
}

- (IBAction)geoBut {
    locationManager = [[CLLocationManager alloc] init];
    

    //    [HUD show:YES];
    
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    [self popToRootController];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
 
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    if([self connected]){

    NSMutableURLRequest *request =
    [[NSMutableURLRequest alloc] initWithURL:
     [NSURL URLWithString:@"http://api.iamchill.co/v1/messages/index/"]];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    
    [request setHTTPMethod:@"POST"];
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    
    NSString *postString = [NSString stringWithFormat:@"id_contact=%ld&id_user=%@&content=%@ %@&type=location",(long)friendid,[userCache valueForKey:@"id_user"],[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude], [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude]];
    
    [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    [locationManager stopUpdatingLocation];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        mutData = [NSMutableData data];
    }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
   
}
- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
   
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [mutData setLength:0];
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mutData appendData:data];
}

@end



