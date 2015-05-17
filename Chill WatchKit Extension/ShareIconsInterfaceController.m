//
//  ShareIconsInterfaceController.m
//  Chill
//
//  Created by Михаил Луцкий on 25.04.15.
//  Copyright (c) 2015 Victor Shamanov. All rights reserved.
//

#import "ShareIconsInterfaceController.h"

@interface ShareIconsInterfaceController () {
    NSArray *json;
    int friendid;

}

@end

@implementation ShareIconsInterfaceController

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
- (void) share:(NSString*)iconType {
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
    [self popToRootController];
    NSLog(@"json %@ postSTR %@ token %@", json, postString, [userCache valueForKey:@"token"] );
}
- (IBAction)clock {
    [self share:@"clock"];
}
- (IBAction)beerbut {
    [self share:@"beer"];

}

- (IBAction)coffeebut {
    [self share:@"coffee"];

}

- (IBAction)stampbut {
    [self share:@"stamp"];

}

- (IBAction)chillbut {
    [self share:@"logo"];

}

- (IBAction)rocketbut {
    [self share:@"rocket"];

}
@end



