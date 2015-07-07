//
//  CHLShareViewController.m
//  Chill
//
//  Created by Виктор Шаманов on 6/1/14.
//  Copyright (c) 2014 Chill. All rights reserved.
//

#import "CHLShareViewController.h"
#import "CHLAdditionalShareViewController.h"
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


@interface CHLShareViewController () <UIActionSheetDelegate, PKImagePickerViewControllerDelegate, CLLocationManagerDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@property(nonatomic, strong) NSString *sendedContentType;

@end

NSMutableData *mutData;

@implementation CHLShareViewController {
    CLLocationManager *locationManager;
}

#pragma mark - View controller lifecycle

- (void)viewDidLoad

{
    
    locationManager = [[CLLocationManager alloc] init];
    self.title = _nameUser;
    
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Share screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - Private methods

- (void)imageChoosed:(UIImage *)image {
    if (self.isNonChillUser) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Email", @"SMS", nil];
        [actionSheet showInView:self.view];
    } else {
        if ([self.delegate respondsToSelector:@selector(shareViewController:didSelectImage:)]) {
            [self.delegate shareViewController:self didSelectImage:image];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Actions

- (IBAction)imageButtonPressed:(id)sender {
    PKImagePickerViewController *imagePicker = [[PKImagePickerViewController alloc] init];
    imagePicker.delegate = self;
    imagePicker.userIdTo = _userIdTo;
    imagePicker.cellStatusView = self.cellStatusView;
    imagePicker.progressViewsDictionary = self.progressViewsDictionary;
    [self presentViewController:imagePicker
                       animated:YES
                     completion:^(){[(UINavigationController *)self.parentViewController popViewControllerAnimated: NO];}];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Share screen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"Image button tapped"
                                                           label:nil
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

- (IBAction)locationButtonPressed:(id)sender {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Sorry"
                                                                       message:@"Go to Preferences to allow Chill use your location."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {}];
        [alert addAction:okayAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    else {
        locationManager = [[CLLocationManager alloc] init];
        
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.dimBackground = NO;
        HUD.delegate = self;
        //    [HUD show:YES];
        
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        [locationManager startUpdatingLocation];
        self.sendedContentType = @"location";
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"Share screen"];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                              action:@"Location button tapped"
                                                               label:nil
                                                               value:nil] build]];
        [tracker set:kGAIScreenName value:nil];
        
        LLACircularProgressView *progressView = [[LLACircularProgressView alloc] initProgressViewWithDummyProgress:0.0 cellStatusView:self.cellStatusView];
        [self.progressViewsDictionary setObject:progressView forKey:[NSNumber numberWithInteger:self.userIdTo]];
        
        [(UINavigationController *)self.parentViewController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [HUD hide:YES];
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    
    // Set custom view mode
    HUD.mode = MBProgressHUDModeCustomView;
    
    HUD.delegate = self;
    HUD.labelText = @"Failed";
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:2];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;

    NSMutableURLRequest *request =
    [[NSMutableURLRequest alloc] initWithURL:
     [NSURL URLWithString:@"http://api.iamchill.co/v1/messages/index/"]];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];

    [request setHTTPMethod:@"POST"];
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];

    NSString *postString = [NSString stringWithFormat:@"id_contact=%ld&id_user=%@&content=%@ %@&type=location",(long)_userIdTo,[userCache valueForKey:@"id_user"],[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude], [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude]];
    
    [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    [locationManager stopUpdatingLocation];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        mutData = [NSMutableData data];
    }
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
     NSLog(@"3 IT HAPPENES MUFUCK");
    [push setChannel:[NSString stringWithFormat:@"us%li",(long)_userIdTo]];
    NSLog(@"4 %ld", (long)_userIdTo);
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
#pragma mark - Image picker delegate

-(void)imageSelected:(UIImage*)img {
    [self imageChoosed:img];
}

-(void)imageSelectionCancelled {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Action sheet delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"additionalShare"])
    {
        CHLAdditionalShareViewController *svc = [segue destinationViewController];
        svc.userIdTo = _userIdTo;
        svc.progressView = [[LLACircularProgressView alloc] initProgressViewWithDummyProgress:0.0 cellStatusView:self.cellStatusView];
        
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
