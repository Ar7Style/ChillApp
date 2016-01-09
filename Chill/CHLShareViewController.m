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
#import "UIViewController+KeyboardAnimation.h"


@interface CHLShareViewController () <UIActionSheetDelegate, PKImagePickerViewControllerDelegate, CLLocationManagerDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottom;
@property(nonatomic, strong) NSString *sendedContentType;
@property(nonatomic, strong) NSString *text;

@property (weak, nonatomic) IBOutlet UILabel *counter;

@end

NSMutableData *mutData;

@implementation CHLShareViewController
    //CLLocationManager *locationManager;
NSInteger defaultValue = 10;


#pragma mark - View controller lifecycle

- (void)viewDidLoad

{
    
    _locationManager = [[CLLocationManager alloc] init];
    self.title = _nameUser;
    _counter.textColor = [UIColor chillMintColor];
    [super viewDidLoad];
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                if ([[UIScreen mainScreen] bounds].size.height < 568) // < iphone 5
                {
                    self.constraintBottom.constant = 160;
                }
            }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    
       
}

-(void)dismissKeyboard {
    [_shareText resignFirstResponder];
}

//- (void)viewDidAppear:(BOOL)animated {
//    
//    
//    if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
//        [_locationManager requestWhenInUseAuthorization];
//    }

//    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
//    {
//        if ([[UIScreen mainScreen] bounds].size.height <= 568) // <= iphone 5
//        {
//            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//            [center addObserver:self selector:@selector(willShowKeyboard) name:UIKeyboardDidShowNotification object:nil];
//            [center addObserver:self selector:@selector(willHideKeyboard) name:UIKeyboardWillHideNotification object:nil];
//        }
//        
//    }
    
//    [super viewDidAppear:animated];
//    
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:@"Share screen"];
//    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
//}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self an_subscribeKeyboardWithAnimations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            if ([[UIScreen mainScreen] bounds].size.height < 568) // < iphone 5
            {
                self.constraintBottom.constant = isShowing ?  CGRectGetHeight(keyboardRect)+20 : 160;
            }
            else
            {
                self.constraintBottom.constant = isShowing ?  CGRectGetHeight(keyboardRect) : 207;
            }
        }

        
        [self.view layoutIfNeeded];
    } completion:nil];
    
}
-(void)viewWillDisappear:(BOOL)animated {
    [self an_unsubscribeKeyboard];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //Iterate through your subviews, or some other custom array of views
    for (UIView *view in self.view.subviews)
        [view resignFirstResponder];
}

#pragma mark - Keyboard Notification

- (void)willShowKeyboard{
    if (!isKeyboardShow){
        isKeyboardShow = true;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-216.0,
                                     self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
    }
}
- (void)backgroundTouchedHideKeyboard:(id)sender
{
    [self.shareText resignFirstResponder];
    
}

- (void)willHideKeyboard{
    isKeyboardShow = false;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+216.0,
                                 self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}
-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {
    //[self.emailField resignFirstResponder];
    [self.shareText resignFirstResponder];
}

#pragma textField methods 

- (IBAction)textDidEditing:(id)sender {
    _counter.text = [NSString stringWithFormat:@"%ld", (long)(defaultValue - _shareText.text.length)];
    if ((long)(defaultValue - _shareText.text.length) <= 0) {
        _counter.textColor = [UIColor redColor];
    }
    else {
        _counter.textColor = [UIColor chillMintColor];
    }
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
        _locationManager = [[CLLocationManager alloc] init];
        
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.dimBackground = NO;
        HUD.delegate = self;
        //    [HUD show:YES];
        
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        [_locationManager startUpdatingLocation];
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

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;

    NSMutableURLRequest *request =
    [[NSMutableURLRequest alloc] initWithURL:
     [NSURL URLWithString:@"http://api.iamchill.co/v2/messages/index/"]];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    [request setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];


    [request setHTTPMethod:@"POST"];
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];

    NSString *postString = [NSString stringWithFormat:@"id_contact=%ld&id_user=%@&content=%@ %@&type=location&date=%@",(long)_userIdTo,[userCache valueForKey:@"id_user"],[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude], [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude], [self getDateTime]];
    
    [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    [_locationManager stopUpdatingLocation];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        mutData = [NSMutableData data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    NSString *message;
    message = [self.sendedContentType isEqualToString:@"location"] ? [NSString stringWithFormat:@"📍 from %@",[userCache valueForKey:@"name"]] : [NSString stringWithFormat:@"%@: %@%@",[userCache valueForKey:@"name"], self.sendedContentType, [self.text isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"#%@", self.text]];
    
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

- (void)shareIconOfType:(NSString *)iconType {
    
    if ([_counter.text integerValue] < 0) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Too long"
                                    
                                                                       message:@"You can only send 10 symbols"
                                    
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        
        
        UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                     
                                                           handler:^(UIAlertAction * action) {}];
        
        [alert addAction:okayAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        _shareText.text = @"";
        _counter.textColor = [UIColor chillMintColor];
        _counter.text = [NSString stringWithFormat:@"%d", 10];
        
    }
    else {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.iamchill.co/v2/messages/index/"]];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    [request setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];

    [request setHTTPMethod:@"POST"];
    
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
        
    [_shareText.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.text = _shareText.text;
    NSString *postString = [NSString stringWithFormat:@"id_contact=%ld&id_user=%@&content=%@&type=icon&text=%@", (long)_userIdTo, [userCache valueForKey:@"id_user"], iconType, _shareText.text];
    NSLog(@"POST STRING: %@", postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        mutData = [NSMutableData data];
    }
    
    LLACircularProgressView *progressView = [[LLACircularProgressView alloc] initProgressViewWithDummyProgress:0.0 cellStatusView:self.cellStatusView];
    [self.progressViewsDictionary setObject:progressView forKey:[NSNumber numberWithInteger:self.userIdTo]];
    
    [(UINavigationController *)self.parentViewController popToRootViewControllerAnimated:YES];
    }
    
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
- (IBAction)questionButtonTapped:(id)sender {
    [self shareIconOfType:@"question"];
    self.sendedContentType = @"❔";
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
        CHLAdditionalShareViewController *asvc = [segue destinationViewController];
        asvc.userIdTo = _userIdTo;
        asvc.cellStatusView = self.cellStatusView;
        asvc.progressViewsDictionary = self.progressViewsDictionary;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
