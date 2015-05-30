//
//  CHLPaperCollectionCell.m
//  Chill
//
//  Created by Ivan Grachev on 20/03/15.
//  Copyright (c) 2015 Victor Shamanov. All rights reserved.
//

#import "CHLPaperCollectionCell.h"
#import "HAPaperCollectionViewController.h"
#import "LLACircularProgressView.h"
#import <Parse/Parse.h>
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"

@interface CHLPaperCollectionCell()
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

- (void)shareIconOfType:(NSString *)iconType {
    [self.viewController dismissPaperCollection];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.iamchill.co/v1/messages/index/"]];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    [request setHTTPMethod:@"POST"];
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    
    NSString *postString = [NSString stringWithFormat:@"id_contact=%ld&id_user=%@&content=%@&type=icon", (long)_friendUserID, [userCache valueForKey:@"id_user"], iconType];
    
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

- (IBAction)clockButtonTapped:(id)sender {
    [self shareIconOfType:@"clock"];
    self.sendedContentType = @"🕒";
}
- (IBAction)drinkButtonTapped:(id)sender {
    [self shareIconOfType:@"beer"];
    self.sendedContentType = @"🍺";
}
- (IBAction)sodaButtonTapped:(id)sender {
    [self shareIconOfType:@"coffee"];
    self.sendedContentType = @"☕️";
}
- (IBAction)blankButtonTapped:(id)sender {
    [self shareIconOfType:@"stamp"];
    self.sendedContentType = @"🌈";
}
- (IBAction)chillButtonTapped:(id)sender {
    [self shareIconOfType:@"logo"];
    self.sendedContentType = @"✌️";
}
- (IBAction)rocketButtonTapped:(id)sender {
    [self shareIconOfType:@"rocket"];
    self.sendedContentType = @"🚀";
}

- (void)awakeFromNib {
}

@end
