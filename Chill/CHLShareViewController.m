//
//  CHLShareViewController.m
//  Chill
//
//  Created by Gregory Tareyev on 6/1/14.
//  Copyright (c) 2016 Chill. All rights reserved.
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
#import "UserCache.h"

#import "ASFirstCVC.h"

#import "ASImageCell.h"
#import "ASImageModel.h"

#import "ANHelperFunctions.h"
#import "ASServerManager.h"
#import "SCLAlertView.h"
#import "UIImage+imageWithColor.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import "Reachability.h"

#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "UIButton+AFNetworking.h"


#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"
#import "LLACircularProgressView.h"
#import "CHLPaperCollectionCell.h"
#import "UIViewController+KeyboardAnimation.h"
#import "CHLShareMoreViewController.h"
#import "CHLIphoneWCManager.h"
#import "NSArray+SameStrings.h"


@interface ButtonToShare1 : UIButton

@property (weak, nonatomic) NSArray *jsonArray;
@property (nonatomic, strong) NSString *typeOfIcon;

@end

@implementation ButtonToShare1



@end

@interface CHLShareViewController () <UIActionSheetDelegate, PKImagePickerViewControllerDelegate, CLLocationManagerDelegate, MBProgressHUDDelegate> {
    NSArray *json;
    MBProgressHUD *HUD;
}


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic) BOOL iconsAreSet;
@property(nonatomic, strong) NSMutableArray *icons;
@property(nonatomic, strong) NSMutableArray *iconNames;
@property (strong, nonatomic) IBOutletCollection(ButtonToShare1) NSArray *buttonsToShare;

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
    NSUserDefaults *cacheSpec = [NSUserDefaults standardUserDefaults];
    if ([cacheSpec boolForKey:@"gotToShareFromHA"]) {
        //        [cacheSpec setBool:NO forKey:@"gotToShareFromHA"];
        _userIdTo = [[cacheSpec valueForKey:@"friendUserID"] integerValue];
        _nameUser = [cacheSpec valueForKey:@"nickName"];
        UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self
                                                                      action:@selector(close:)];
        [backButton setTintColor:[UIColor chillMintColor]];
        self.navigationItem.leftBarButtonItem = backButton;
        
    }
    [self.activityIndicator startAnimating];
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
    NSLog(@"name %@ id %li", _nameUser, (long)_userIdTo);
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithTitle:@"More" style:UIBarButtonItemStylePlain target:self action:@selector(presentShareMoreViewController)];
    [moreButton setTintColor:[UIColor chillMintColor]];
    self.navigationItem.rightBarButtonItem = moreButton;
    
}

- (void)presentShareMoreViewController
{
    [self performSegueWithIdentifier:@"additionalShare" sender:nil];
}

-(BOOL) isInternetConnection {
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            SCLAlertView* alert = [[SCLAlertView alloc] init];
            [alert showError:self.parentViewController title:@"Oups" subTitle:@"Please, check your internet connection" closeButtonTitle:@"OK" duration:0.0f];
        });
        return NO;
    }
    return YES;
}

-(void) getUserIconsFromServer {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
    [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    [manager GET:[NSString stringWithFormat:@"http://api.iamchill.co/v2/icons/user/id_user/%@",[NSUserDefaults userID]] parameters:nil success:^(NSURLSessionTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"]) {
            json = [responseObject objectForKey:@"response"];
            NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
            NSArray *oldFavoritesNames = [userCache arrayForKey:@"FavoritesArray"];
            NSMutableArray *newFavoriteNames = [[NSMutableArray alloc] init];
            for (int i=0; i<json.count; ++i) {
                [newFavoriteNames addObject:[NSString stringWithFormat:@"%@",[json[i] valueForKey:@"name"]]];
            }
            if ([newFavoriteNames sameStrings:oldFavoritesNames] && self.iconsAreSet) {
                return;
            }
            [[CHLIphoneWCManager sharedManager] sendFavoriteIconsNames:newFavoriteNames];
            for (int i=0; i<json.count; ++i) {
                NSString *imageName = [NSString stringWithFormat:@"%@",[json[i] valueForKey:@"name"]];
                NSURL *imageURL = [NSURL URLWithString:[json[i] valueForKey:@"size66"]];
                [[[NSURLSession sharedSession] dataTaskWithURL:imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    [self saveImageData:data withName:imageName];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [_buttonsToShare[i] setImage:[UIImage imageWithData:data scale:[UIScreen mainScreen].scale] forState:UIControlStateNormal];
                        ButtonToShare1 *buttonToShare = _buttonsToShare[i];
                        buttonToShare.typeOfIcon = imageName;
                        [_buttonsToShare[i] addTarget:self action:@selector(sendIcon:) forControlEvents:UIControlEventTouchUpInside];
                        [_activityIndicator setHidden:YES];
                    });
                }] resume];
            }
            NSLog(@"JSON FROM LOAD DATA: %@", json);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        SCLAlertView* alert = [[SCLAlertView alloc] init];
        [alert showError:self.parentViewController title:@"Oups" subTitle:@"Please, check your internet connection" closeButtonTitle:@"OK" duration:0.0f];
        NSLog(@"Error from load data: %@", error);
    }];
}

-(void) sendIcon:(ButtonToShare1 *)sender {
    [self shareIconOfType:[NSString stringWithFormat:@"%@", sender.typeOfIcon]];
    NSLog(@"%@ was send!", sender.typeOfIcon);
}

- (void)saveImageData:(NSData *)imageData withName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:name];
    [imageData writeToFile:savedImagePath atomically:NO];
}

-(void)dismissKeyboard {
    [_shareText resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [_locationManager requestWhenInUseAuthorization];
    }
    
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Share screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)setupWithStoredIcons {
    if ([self fetchAllIconsFromStorage]) {
        self.iconsAreSet = YES;
        for (int i = 0; i < self.icons.count; i++) {
            ButtonToShare1 *button = _buttonsToShare[i];
            [button setImage:self.icons[i] forState:UIControlStateNormal];
            button.typeOfIcon = self.iconNames[i];
            [button addTarget:self action:@selector(sendIcon:) forControlEvents:UIControlEventTouchUpInside];
            [_activityIndicator setHidden:YES];
        }
    }
}

- (UIImage *)fetchImageWithName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:name];
    NSData *pngData = [NSData dataWithContentsOfFile:savedImagePath];
    return [UIImage imageWithData:pngData scale:[UIScreen mainScreen].scale];
}

- (BOOL)fetchAllIconsFromStorage {
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    NSArray *favorites = [userCache objectForKey:@"FavoritesArray"];
    if (favorites != nil) {
        NSMutableArray *images = [[NSMutableArray alloc] init];
        for (NSString *name in favorites) {
            UIImage *image = [self fetchImageWithName:name];
            if (image != nil) {
                [images addObject:image];
            }
        }
        if (images.count == favorites.count) {
            self.icons = images;
            self.iconNames = [favorites mutableCopy];
            return YES;
        }
    }
    return NO;
}
            
            
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupWithStoredIcons];
    if ([self isInternetConnection]) {
        ANDispatchBlockToBackgroundQueue(^{
            [self getUserIconsFromServer];
        });
    }
    
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


#pragma mark - Keyboard Notification


- (void)backgroundTouchedHideKeyboard:(id)sender
{
    [self.shareText resignFirstResponder];
    
}

-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {
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
                     completion:^(){
                         NSUserDefaults *cacheSpec = [NSUserDefaults standardUserDefaults];
                         if ([cacheSpec boolForKey:@"gotToShareFromHA"]) {
                             [cacheSpec setBool:NO forKey:@"gotToShareFromHA"];
                             [self dismissViewControllerAnimated:YES completion:nil];
                         }else {
                             [(UINavigationController *)self.parentViewController popViewControllerAnimated: NO];
                         }
                         
                     }];
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
        
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        [_locationManager startUpdatingLocation];
        self.sendedContentType = @"location";
        // [_locationManager stopUpdatingLocation];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"Share screen"];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                              action:@"Location button tapped"
                                                               label:nil
                                                               value:nil] build]];
        [tracker set:kGAIScreenName value:nil];
        
        LLACircularProgressView *progressView = [[LLACircularProgressView alloc] initProgressViewWithDummyProgress:0.0 cellStatusView:self.cellStatusView];
        [self.progressViewsDictionary setObject:progressView forKey:[NSNumber numberWithInteger:self.userIdTo]];
        NSUserDefaults *cacheSpec = [NSUserDefaults standardUserDefaults];
        if ([cacheSpec boolForKey:@"gotToShareFromHA"]) {
            [cacheSpec setBool:NO forKey:@"gotToShareFromHA"];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else {
            [(UINavigationController *)self.parentViewController popToRootViewControllerAnimated:YES];
        }
        [_locationManager stopUpdatingLocation];
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
    //[_locationManager stopUpdatingLocation];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        mutData = [NSMutableData data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    //    NSString *message;
    //    message = [self.sendedContentType isEqualToString:@"location"] ? [NSString stringWithFormat:@"📍 from %@",[userCache valueForKey:@"name"]] : [NSString stringWithFormat:@"%@: %@%@",[userCache valueForKey:@"name"], self.sendedContentType, [self.text isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"#%@", self.text]];
    //
    //    NSDictionary *data = @{
    //                           @"alert": message,
    //                           @"type": @"Location",
    //                           @"sound": @"default",
    //                           @"badge" : @1,
    //                           @"fromUserId": [userCache valueForKey:@"id_user"]
    //                           };
    //    PFPush *push = [[PFPush alloc] init];
    //    [push setChannel:[NSString stringWithFormat:@"us%li",(long)_userIdTo]];
    //
    //    [push setData:data];
    //    [push sendPushInBackground];
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
        NSMutableURLRequest *requestForNotifications = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.iamchill.co/v2/notifications/message"]];
        
        [requestForNotifications setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
        [requestForNotifications setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
        [requestForNotifications setHTTPMethod:@"POST"];
        NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
        [_shareText.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        self.text = _shareText.text;
        NSString *postStringForNotifications = [NSString stringWithFormat:@"id_contact=%ld&id_user=%@&content=%@&type=icon&text=%@", (long)_userIdTo, [userCache valueForKey:@"id_user"], iconType, _shareText.text];
        [requestForNotifications setHTTPBody:[postStringForNotifications dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLConnection *connectionForNotifications = [[NSURLConnection alloc] initWithRequest:requestForNotifications delegate:self];
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.iamchill.co/v2/messages/index"]];
        [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
        [request setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
        
        [request setHTTPMethod:@"POST"];
        
        
        [_shareText.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        self.text = _shareText.text;
        NSString *postString = [NSString stringWithFormat:@"id_contact=%ld&id_user=%@&content=%@&type=icon&text=%@", (long)_userIdTo, [userCache valueForKey:@"id_user"], iconType, [_shareText.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        NSLog(@"POST STRING: %@", postString);
        
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (connection) {
            mutData = [NSMutableData data];
        }
        
        LLACircularProgressView *progressView = [[LLACircularProgressView alloc] initProgressViewWithDummyProgress:0.0 cellStatusView:self.cellStatusView];
        [self.progressViewsDictionary setObject:progressView forKey:[NSNumber numberWithInteger:self.userIdTo]];
        NSUserDefaults *cacheSpec = [NSUserDefaults standardUserDefaults];
        if ([cacheSpec boolForKey:@"gotToShareFromHA"]) {
            [cacheSpec setBool:NO forKey:@"gotToShareFromHA"];
            NSLog(@"11");
            [self dismissViewControllerAnimated:YES completion:nil];
        }else {
            NSLog(@"22");
            [(UINavigationController *)self.parentViewController popToRootViewControllerAnimated:YES];
        }
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Share screen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:[NSString stringWithFormat:@"Shared icon of type: %@", iconType]
                                                           label:nil
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
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
        CHLShareMoreViewController *shareMoreVC = [segue destinationViewController];
        shareMoreVC.userIdTo = _userIdTo;
        shareMoreVC.cellStatusView = self.cellStatusView;
        shareMoreVC.progressViewsDictionary = self.progressViewsDictionary;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
}




- (IBAction)close:(id)sender {
    NSUserDefaults *cacheSpec = [NSUserDefaults standardUserDefaults];
    [cacheSpec setBool:NO forKey:@"gotToShareFromHA"];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
