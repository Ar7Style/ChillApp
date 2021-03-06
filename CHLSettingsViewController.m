//
//  CHLSettingsViewController.m
//  Chill
//
//  Created by Tareyev Gregory on 04.02.15.
//  Copyright (c) 2015 Tareyev Gregory. All rights reserved.
//
#import "CHLSettingsViewController.h"
#import "AUTHViewController.h"
#import "APPROVEDViewController.h"
#import <Social/Social.h>
#import <Parse/Parse.h>
#import "CHLFriendsListViewController.h"
#import "Reachability.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"
#import "CHLFriendsListViewController.h"
#import "UIViewController+KeyboardAnimation.h"
#import <AFNetworking/AFNetworking.h>
#import "UserCache.h"

#import "SCLAlertView.h"

@interface CHLSettingsViewController () {
    NSMutableArray *json;
    
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottom;

@end


@implementation CHLSettingsViewController
{
    NSArray *_locations;
}

- (BOOL)connected
{
    return [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable;
}

- (void)viewDidLoad {
    
    [self loadSettings];
    
}

//-(void)viewWillAppear:(BOOL)animated {
//    __weak __typeof(self) weakSelf = self;
//    [self an_subscribeKeyboardWithAnimations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {
//        __typeof__(self) strongSelf = weakSelf;
//     self.constraintBottom.constant = isShowing ?  CGRectGetHeight(keyboardRect) : 20;
//        
//        [self.view layoutIfNeeded];
//    } completion:nil];
//    [self.view layoutIfNeeded];
//
//}
//
//-(void)viewWillDisappear:(BOOL)animated {
//    [self an_unsubscribeKeyboard];
//}




- (void)viewDidAppear:(BOOL)animated {
    
    
    self.navigationController.view.clipsToBounds=YES;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if ([[UIScreen mainScreen] bounds].size.height <= 568) // < iphone 5
        {
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center addObserver:self selector:@selector(willShowKeyboard) name:UIKeyboardDidShowNotification object:nil];
            [center addObserver:self selector:@selector(willHideKeyboard) name:UIKeyboardWillHideNotification object:nil];
        }
    }
    
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Settings screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}


- (void) conRefused {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Connection refused"
                                                                   message:@"Check your Internet connection"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {}];
    [alert addAction:okayAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) errorShow: (NSString*)message {
    SCLAlertView* alert = [[SCLAlertView alloc] init];
    [alert showError:self.parentViewController title:@"Oups" subTitle:message closeButtonTitle:@"OK" duration:0.0f];

}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //Iterate through your subviews, or some other custom array of views
    for (UIView *view in self.view.subviews)
        [view resignFirstResponder];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard Notification

- (void)willShowKeyboard{
    if (!isKeyboardShow){
        if (![self.emailField isFirstResponder]) {
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
}

- (void)backgroundTouchedHideKeyboard:(id)sender
{
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}


- (void)willHideKeyboard{
    if (![self.emailField isFirstResponder]) {
        isKeyboardShow = false;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+216.0,
                                     self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
    }
}
-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {
    //[self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}



# pragma mark - Save and Load

-(void)saveSettings {
    [_emailField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [_passwordField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
      [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
        [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
        NSDictionary *parameters = @{@"id_user": [[NSUserDefaults standardUserDefaults] valueForKey:@"id_user"], @"email": _emailField.text, @"password":_passwordField.text};
    
        [manager POST:@"http://api.iamchill.co/v2/users/update" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([[responseObject valueForKey:@"status"] isEqualToString:@"failed"]){
                [self errorShow:@"It seems that the entered email or password is incorrect"];
            }
            else if ([[responseObject valueForKey:@"status"] isEqualToString:@"success"]) {
                        NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
                                [userCache setValue:[[responseObject valueForKey:@"response"] valueForKey:@"email"] forKey:@"email"];
                                [userCache setValue:[[responseObject valueForKey:@"response"] valueForKey:@"password"] forKey:@"password"];
                                [userCache synchronize];

                                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                                [currentInstallation addUniqueObject:[NSString stringWithFormat:@"us%@",[userCache valueForKey:@"id_user"]] forKey:@"channels"];
                                [currentInstallation saveInBackground];
                                
                                [self setupGAUserID: [userCache valueForKey:@"id_user"]];
                                userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
                
                }
        }
        failure:^(AFHTTPRequestOperation *operation2, NSError *error2) {
                    [self errorShow:@"Please, check Your internet connection"];
                }];
}

-(void)loadSettings {
    
    NSUserDefaults *userCache = [NSUserDefaults standardUserDefaults];
    _nickNameLabel.text = [userCache valueForKey:@"login_user"];

    
    
    self.emailField.text = [userCache valueForKey:@"email"];
    self.passwordField.text = [userCache valueForKey:@"password"];
    
   // [userCache synchronize];
    

}

# pragma mark - Actions

- (IBAction)showEmail:(id)sender {
    // Email Subject
    NSString *emailTitle = @"One more thing in Chill";
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"kirill.chekanov1@gmail.com"];
    
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




- (IBAction)actionTextChanged:(id)sender {
    
   
}

- (IBAction)Done:(id)sender {
    
        [self saveSettings];
        [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) setupGAUserID: (NSString *)userID {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // You only need to set User ID on a tracker once
    [tracker set:@"&uid" value:userID];
    [tracker set:kGAIScreenName value:@"Auth screen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"User Sign In"
                                                           label:nil
                                                           value:nil] build]];
}


- (IBAction)logout:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Exit from Chill"
                                                                   message:@"Are You sure?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* declineAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {}];
    
    UIAlertAction* logoutAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self userChoosesLogout];
                                                         }];
    
    [alert addAction:declineAction];
    [alert addAction:logoutAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)userChoosesLogout {
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    _locations = nil;
    CHLFriendsListViewController* flvc = [[CHLFriendsListViewController alloc] init];
    [flvc.tableView reloadData];
    [userCache setBool:false forKey:@"isAuth"];
    [userCache setBool:false forKey:@"isApproved"];
    [userCache synchronize];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation removeObject:[NSString stringWithFormat:@"us%@",[userCache valueForKey:@"id_user"]] forKey:@"channels"];
    [currentInstallation saveInBackground];
    AUTHViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Chill.AuthViewController"];
    
    [self dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:vc animated:NO completion:nil];
    
}



#pragma mark - TextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.emailField])
    {
        [self.passwordField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return NO;
}


@end