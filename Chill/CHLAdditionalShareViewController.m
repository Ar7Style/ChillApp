//
//  CHLAdditionalShareViewController.m
//  Chill
//
//  Created by Tareyev Gregory on 05.07.15.
//  Copyright (c) 2015 Victor Shamanov. All rights reserved.
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

@interface CHLAdditionalShareViewController ()<UIActionSheetDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
    
}

@property(nonatomic, strong) NSString *sendedContentType;


@end

NSMutableData *mutData;

@implementation CHLAdditionalShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"Additional _userIdTo HERE : %ld",  self.userIdTo);
    
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
     NSLog(@"2 IT HAPPENES MUFUCK");
    [push setChannel:[NSString stringWithFormat:@"us%li",(long)_userIdTo]];
    NSLog(@"5 %ld", (long)_userIdTo);
    [push setData:data];
    [push sendPushInBackground];
}

- (void)shareIconOfType:(NSString *)iconType {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.iamchill.co/v1/messages/index/"]];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    [request setHTTPMethod:@"POST"];
    
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    
    NSString *postString = [NSString stringWithFormat:@"id_contact=%ld&id_user=%@&content=%@&type=icon", (long)_userIdTo, [userCache valueForKey:@"id_user"], iconType];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        mutData = [NSMutableData data];
    }
    
    LLACircularProgressView *progressView = [[LLACircularProgressView alloc] initProgressViewWithDummyProgress:0.0 cellStatusView:self.cellStatusView];
    [self.progressViewsDictionary setObject:progressView forKey:[NSNumber numberWithInteger:self.userIdTo]];
    
    [(UINavigationController *)self.parentViewController popToRootViewControllerAnimated:YES];
    NSLog(@"1 IT HAPPENES MUFUCK");
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Share screen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:[NSString stringWithFormat:@"Shared icon of type: %@", iconType]
                                                           label:nil
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
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

#pragma mark - Additional icons

- (IBAction)trophyButtonPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self shareIconOfType:@"trophy"];
    self.sendedContentType = @"🏆";
}

- (IBAction)gymButtonTapped:(id)sender {
    [self shareIconOfType:@"gym"];
    self.sendedContentType = @"💪🏼";
}
- (IBAction)flagButtonTapped:(id)sender {
    [self shareIconOfType:@"flag"];
    self.sendedContentType = @"🏁";
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
