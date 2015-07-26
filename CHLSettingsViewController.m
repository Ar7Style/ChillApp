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

@interface CHLSettingsViewController () {
    NSMutableArray *json;
    
}

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

- (void)viewDidAppear:(BOOL)animated {
    
    self.navigationController.view.clipsToBounds=YES;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(willShowKeyboard) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(willHideKeyboard) name:UIKeyboardWillHideNotification object:nil];
    
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
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {}];
    [alert addAction:okayAction];
    [self presentViewController:alert animated:YES completion:nil];
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
    
    self.email = _emailField.text;
    self.password = _passwordField.text;

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://178.62.151.46/v1/users/update/"]]];
    //                [request setValue:@"Chill" forHTTPHeaderField:@"User-Agent"];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    
    [request setHTTPMethod:@"POST"];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSString *postString = [NSString stringWithFormat:@"id_user=%@&email=%@&password=%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"id_user"],  _emailField.text, _passwordField.text];
    
    //NSLog(@"ID_USER V NS USER DEFAULTS POLUCHILSYA SLEDUYUWIY: %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"id_user"]);
    //
    //                [request setValue:[NSString
    //                                   stringWithFormat:@"%lu", (unsigned long)[postString length]]
    //                forHTTPHeaderField:@"Content-length"];
    //
    [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    json = [NSJSONSerialization JSONObjectWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] options:NSJSONReadingMutableContainers error:&error];
    
    
    NSLog(@"REQUEST's STATUS: %@", json);
    
    if ([[json valueForKey:@"status"] isEqualToString:@"failed"]){
        [self errorShow:@"It seems that the entered email or password is incorrect"];
    }
    else if ([[json valueForKey:@"status"] isEqualToString:@"success"]) {
        
        NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
        [userCache setValue:[[json valueForKey:@"response"] valueForKey:@"email"] forKey:@"email"];
        [userCache setValue:[[json valueForKey:@"response"] valueForKey:@"password"] forKey:@"password"];
        
        
        [userCache synchronize];
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addUniqueObject:[NSString stringWithFormat:@"us%@",[userCache valueForKey:@"id_user"]] forKey:@"channels"];
        [currentInstallation saveInBackground];
        
        [self setupGAUserID: [userCache valueForKey:@"id_user"]];
        userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
        
        
        
    }

}

-(void)loadSettings {
    
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    _nickNameLabel.text = [userCache valueForKey:@"login_user"];

    
    
    self.emailField.text = [userCache valueForKey:@"email"];
    self.passwordField.text = [userCache valueForKey:@"password"];
    
   // [userCache synchronize];
    
}

# pragma mark - Actions


- (IBAction)actionTextChanged:(id)sender {
    
   // [self saveSettings];
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