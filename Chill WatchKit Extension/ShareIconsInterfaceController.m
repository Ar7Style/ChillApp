//
//  ShareIconsInterfaceController.m
//  Chill
//
//  Created by Михаил Луцкий on 25.04.15.
//  Copyright (c) 2015 Chill. All rights reserved.
//

#import "ShareIconsInterfaceController.h"
#import <Parse/Parse.h>

#import "Reachability.h"

@interface ShareIconsInterfaceController () {
    NSArray *json;
    int friendid;
    Reachability *internetReachableFoo;

}

@end

@implementation ShareIconsInterfaceController
- (BOOL)connected
{
    return [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable;
}
- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    friendid = [context intValue];
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}
- (void) share:(NSString*)iconType icon:(NSString*)iconLogo {
    if([self connected]){

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.iamchill.co/v1/messages/index/"]];
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];

    [request setValue:[userCache valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    [request setHTTPMethod:@"POST"];
    
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSString *postString = [NSString stringWithFormat:@"id_contact=%d&id_user=%@&content=%@&type=icon", friendid, [userCache valueForKey:@"id_user"], iconType];
    
    //[request setValue:[NSString
    //                   stringWithFormat:@"%lu", (unsigned long)[postString length]]
    //forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    json = [NSJSONSerialization JSONObjectWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] options:NSJSONReadingMutableContainers error:&error];
    NSString *message = [NSString stringWithFormat:@"%@: %@",[userCache valueForKey:@"name"], iconLogo];
    
    NSDictionary *data = @{
                           @"alert": message,
                           @"type": @"Location",
                           @"sound": @"default",
                           @"badge" : @1,
                           @"fromUserId": [userCache valueForKey:@"id_user"]
                           };
    [Parse setApplicationId:@"vlSSbINvhblgGlipWpUWR6iJum3Q2xd7GthrDVUI" clientKey:@"ZR93BdaHDWTzjIvfDur3X02D3tNs0gATKwY1srh8"];

    PFPush *push = [[PFPush alloc] init];
    
    [push setChannel:[NSString stringWithFormat:@"us%li",(long)friendid]];
    [push setData:data];
    [push sendPushInBackground];
    [self popToRootController];
    NSLog(@"json %@ postSTR %@ token %@", json, postString, [userCache valueForKey:@"token"] );
    }
}
- (IBAction)clock {
    [self share:@"clock" icon:@"🕒"];
}
- (IBAction)beerbut {
    [self share:@"beer" icon:@"🍺"];

}

- (IBAction)coffeebut {
    [self share:@"coffee" icon:@"☕️"];

}

- (IBAction)stampbut {
    [self share:@"stamp" icon:@"🌈"];

}

- (IBAction)chillbut {
    [self share:@"logo" icon:@"✌️"];

}

- (IBAction)rocketbut {
    [self share:@"rocket" icon:@"🚀"];

}
@end



