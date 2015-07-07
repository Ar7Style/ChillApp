//
//  InterfaceController.m
//  Chill WatchKit Extension
//
//  Created by Михаил Луцкий on 04.03.15.
//  Copyright (c) 2015 Chill. All rights reserved.
//

#import "InterfaceController.h"
#import "CHLTableWatch.h"
#import "JSONLoader.h"
#import "FriendsJSON.h"
#import "Reachability.h"
@interface InterfaceController() {
    Reachability *internetReachableFoo;

}

@end


@implementation InterfaceController {
    NSArray *_locations;
}
- (BOOL)connected
{
    return [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable;
}
- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    NSLog(@"tap");
    FriendsJSON *location = [_locations objectAtIndex:rowIndex];

    [self pushControllerWithName:@"mess" context:location.id_contact];
}
- (void) loadJSON {
    if([self connected]){
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"http://api.iamchill.co/v1/contacts/index/id_user/%@", [userCache valueForKey:@"id_user"]);
        NSArray *preLoad =[[[JSONLoader alloc] init] locationsFromJSONFile:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://api.iamchill.co/v1/contacts/index/id_user/%@", [userCache valueForKey:@"id_user"]]] typeJSON:@"Friends"];
        if (![preLoad isEqualToArray:_locations])
        {
            _locations = preLoad;
            [self configureTableWithData];
        }
    });
    }
    else {
        [self.table setNumberOfRows:1 withRowType:@"cell"];
        CHLTableWatch* theRow = [self.table rowControllerAtIndex:0];

        [theRow.lblTitle setText:@"Connection refuesed"];

    }
}
- (void)configureTableWithData {
    
    [self.table setNumberOfRows:[_locations count] withRowType:@"cell"];
    for (NSInteger i = 0; i < self.table.numberOfRows; i++) {
        CHLTableWatch* theRow = [self.table rowControllerAtIndex:i];
        FriendsJSON *location = [_locations objectAtIndex:i];
        //MyDataObject* dataObj = [dataObjects objectAtIndex:i];
        //theRow.title = @"hhhh";
        [theRow.lblTitle setText:location.name];
        //[theRow.rowIcon setImage:dataObj.image];
    }
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    //[self populateData];
    // Configure interface objects here.
}
- (void)presentControllerWithNames:(NSArray *)names contexts:(NSArray *)contexts{
    NSMutableArray *controllers=[[NSMutableArray alloc] init];
    for (NSInteger i=0; i<3; ++i) {
        [controllers addObject:@"yourInterfaceControllerIdentifier"];
    }
    
    
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self loadJSON];
    [self presentControllerWithNames:@[@"First", @"Second", @"Third"] contexts:@[self,self,self]];

//    NSArray *array = @[@"name", @"mmm", @"mmm"];
//    [self configureTableWithData:array];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



