//
//  CHLAdditionalShareViewController.m
//  Chill
//
//  Created by Tareyev Gregory on 05.07.15.
//  Copyright (c) 2015 Chill. All rights reserved.
//

#import "CHLAdditionalShareViewController.h"
#import "CHLShareViewController.h"
#import <Parse/Parse.h>
#import "UIColor+ChillColors.h"
#import "PKImagePickerViewController.h"
#import "MBProgressHUD.h"
#import <CoreLocation/CoreLocation.h>
#import "FriendsJSON.h"
#import "JSONLoader.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"
#import "LLACircularProgressView.h"
#import "CHLPaperCollectionCell.h"
#import "LLACircularProgressView.h"




@interface CHLAdditionalShareViewController ()<UIActionSheetDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
    
}

@property(nonatomic, strong) NSString *sendedContentType;

@end

NSMutableData *mutData;

@implementation CHLAdditionalShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    NSString *message;
    if ([self.sendedContentType isEqualToString:@"location"]) {
        message = [NSString stringWithFormat:@"📍 from %@",[userCache valueForKey:@"name"]];
    }
    else {
        message = [NSString stringWithFormat:@"%@: %@",[userCache valueForKey:@"name"], self.sendedContentType];
    }
    NSDictionary *data = @{
                           @"alert": message,
                           @"type": @"Location",
                           @"sound": @"default",
                           @"badge" : @1,
                           @"fromUserId": [userCache valueForKey:@"id_user"]
                           };
    PFPush *push = [[PFPush alloc] init];
    
    [push setChannel:[NSString stringWithFormat:@"us%li",(long)_userIdTo]];
    
    [push setData:data];
    [push sendPushInBackground];
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
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.iamchill.co/v2/messages/index/"]];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    [request setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];

    [request setHTTPMethod:@"POST"];
    
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    
    NSString *postString = [NSString stringWithFormat:@"id_contact=%ld&id_user=%@&content=%@&type=icon&date=%@", (long)_userIdTo, [userCache valueForKey:@"id_user"], iconType, [self getDateTime]];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        mutData = [NSMutableData data];
    }
    
    LLACircularProgressView *progressView = [[LLACircularProgressView alloc] initProgressViewWithDummyProgress:0.0 cellStatusView:self.cellStatusView];
    [self.progressViewsDictionary setObject:progressView forKey:[NSNumber numberWithInteger:self.userIdTo]];
    
    [(UINavigationController *)self.parentViewController popToRootViewControllerAnimated:YES];
    NSLog(@"1 IT HAPPENES MUFUCK %ld", (long)self.userIdTo);
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Share screen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:[NSString stringWithFormat:@"Shared icon of type: %@", iconType]
                                                           label:nil
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

- (IBAction)plusButtonTapped:(id)sender {
    [self shareIconOfType:@"plus"];
    self.sendedContentType = @"+";
}

- (IBAction)minusButtonTapped:(id)sender {
    [self shareIconOfType:@"minus"];
    self.sendedContentType = @"-";
}
- (IBAction)dollarButtonTapped:(id)sender {
    [self shareIconOfType:@"dollar"];
    self.sendedContentType = @"💲";
}
- (IBAction)sleepButtonTapped:(id)sender {
    [self shareIconOfType:@"sleep"];
    self.sendedContentType = @"💤";
}
- (IBAction)pizzaButtonTapped:(id)sender {
    [self shareIconOfType:@"pizza"];
    self.sendedContentType = @"🍕";
}
- (IBAction)ballButtonTapped:(id)sender {
    [self shareIconOfType:@"ball"];
    self.sendedContentType = @"⚽️";
}

#pragma mark - Additional icons

- (IBAction)trophyButtonPressed:(id)sender {
    [self shareIconOfType:@"trophy"];
    self.sendedContentType = @"🏆";
}

- (IBAction)heartButtonTapped:(id)sender {
    [self shareIconOfType:@"heart"];
    self.sendedContentType = @"❤️";
}
- (IBAction)controllerButtonTapped:(id)sender {
    [self shareIconOfType:@"controller"];
    self.sendedContentType = @"🎮";
}
- (IBAction)telephoneButtonTapped:(id)sender {
    [self shareIconOfType:@"telephone"];
    self.sendedContentType = @"📞";
}
- (IBAction)bookButtonTapped:(id)sender {
    [self shareIconOfType:@"book"];
    self.sendedContentType = @"📖";
}
- (IBAction)wavesButtonTapped:(id)sender {
    [self shareIconOfType:@"waves"];
    self.sendedContentType = @"💭";
}

- (IBAction)backButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    float currentProgress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    LLACircularProgressView *currentProgressView = [self.progressViewsDictionary objectForKey:[NSNumber numberWithInteger:self.userIdTo]];
    [currentProgressView setProgress:(currentProgress > currentProgressView.progress ? currentProgress : currentProgressView.progress) animated:YES];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showEmail:(id)sender {
    // Email Subject
    NSString *emailTitle = @"One more thing in Chill";
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"kirill.chekanov2@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    if (mc != nil)
    {
        [self presentViewController:mc animated:YES completion:NULL];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
