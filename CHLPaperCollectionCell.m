//
//  CHLPaperCollectionCell.m
//  Chill
//
//  Created by Ivan Grachev on 20/03/15.
//  Copyright (c) 2015 Chill. All rights reserved.
//

#import "CHLPaperCollectionCell.h"
#import "HAPaperCollectionViewController.h"
#import "LLACircularProgressView.h"
#import "CHLShareViewController.h"
#import <Parse/Parse.h>

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"

#import <AFNetworking/AFNetworking.h>
#import "UIButton+AFNetworking.h"

#import "UserCache.h"



@interface CHLPaperCollectionCell() {
    NSArray* json;
}
@property(nonatomic, strong) NSMutableData *mutData;
@property(nonatomic, weak) HAPaperCollectionViewController *viewController;
@property(nonatomic, strong) NSMutableDictionary *progressViewsDictionary;
@property(nonatomic, strong) NSString *sendedContentType;


@end

@implementation CHLPaperCollectionCell

- (NSDictionary *)progressViewsDictionary {
    if (!_progressViewsDictionary) {
        _progressViewsDictionary = self.viewController.progressViewsDictionary;
    }
    return _progressViewsDictionary;
}

- (HAPaperCollectionViewController *)viewController {
    if (!_viewController) {
        UIResponder *responder = self;
        while ([responder isKindOfClass:[UIView class]])
            responder = [responder nextResponder];
        if ([responder isKindOfClass:[HAPaperCollectionViewController class]]) {
            _viewController = (HAPaperCollectionViewController *)responder;
        }
        else {
            _viewController = nil;
        }
    }
    return _viewController;
}

- (IBAction)showIcon:(ButtonToShow *)sender {
    
}

- (NSString*) getDateTime {
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    
    [currDate timeIntervalSince1970];
    // NSTimeZone* generalTimeZone1 = [NSTimeZone timeZoneWithName:@"CET"];
    
    //[dateFormatter setTimeZone: generalTimeZone1];
    [dateFormatter setDateFormat:@"dd.MM.YY HH:mm:ss"];
    NSString* dateString =[NSString stringWithFormat:@"%lld",milliseconds];
    NSLog(@"%@", dateString);
    
    return dateString;
}

- (void)shareIconOfType:(NSString *)iconType {
    [self.viewController dismissPaperCollection:(nil)];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.iamchill.co/v2/messages/index/"]];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    [request setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    
    [request setHTTPMethod:@"POST"];
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    
    NSString *postString = [NSString stringWithFormat:@"id_contact=%ld&id_user=%@&content=%@&type=icon&date=%@", (long)_friendUserID, [userCache valueForKey:@"id_user"], iconType, [self getDateTime]];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        self.mutData = [NSMutableData data];
    }
    
    LLACircularProgressView *progressView = [[LLACircularProgressView alloc] initProgressViewWithDummyProgress:0.0 cellStatusView:self.viewController.cellStatusView];
    [self.progressViewsDictionary setObject:progressView forKey:[NSNumber numberWithInteger:_friendUserID]];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Cards screen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:[NSString stringWithFormat:@"%@ button tapped", iconType]
                                                           label:nil
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    NSString *message = [NSString stringWithFormat:@"%@: %@",[userCache valueForKey:@"name"], self.sendedContentType];
    NSDictionary *data = @{
                           @"alert": message,
                           @"type": @"Location",
                           @"sound": @"default",
                           @"badge" : @1,
                           @"fromUserId": [userCache valueForKey:@"id_user"]
                           };
    PFPush *push = [[PFPush alloc] init];
    
    [push setChannel:[NSString stringWithFormat:@"us%li",(long)_friendUserID]];
    [push setData:data];
    [push sendPushInBackground];
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    float currentProgress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    LLACircularProgressView *currentProgressView = [self.progressViewsDictionary objectForKey:[NSNumber numberWithInteger:_friendUserID]];
    [currentProgressView setProgress:(currentProgress > currentProgressView.progress ? currentProgress : currentProgressView.progress) animated:YES];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.mutData setLength:0];
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.mutData appendData:data];
}


- (void)awakeFromNib {
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    [manager.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
//    [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
//    [manager GET:[NSString stringWithFormat:@"http://api.iamchill.co/v2/messages/index/id_user/%@/id_contact/%ld",[NSUserDefaults userID], (long)_friendUserID] parameters:nil success:^(NSURLSessionTask *task, id responseObject) {
//        if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"]) {
//            json = [responseObject objectForKey:@"response"];
//            NSLog(@"ya zagruzilsya");
//          
//
//            }
//        else {
//            NSLog(@"awakeFromNib json fail. id_user: %@, id_contact: %ld, token: %@", [NSUserDefaults userID], (long)_friendUserID, [NSUserDefaults userToken]);
//        }
//        NSLog(@"JSON FROM LOAD DATA: %@", json);
//
//    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        NSLog(@"Error from load data: %@", error);
//    }];

}

@end
