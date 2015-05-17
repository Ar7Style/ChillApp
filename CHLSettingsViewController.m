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

@interface CHLSettingsViewController ()

@end

static NSString* ksettingsEmail    = @"email";
static NSString* ksettingsPassword = @"password";


@implementation CHLSettingsViewController
{
    NSArray *_locations;
}

- (void)viewDidLoad {
    
   // [super viewDidLoad];
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    
        _nickNameLabel.text = [userCache valueForKey:@"login_user"];
    NSLog(@"NAME IN SETTINGS: %@", [userCache valueForKey:@"name"]);

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
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
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
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}



# pragma mark - Save and Load

-(void)saveSettings {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults]; //singleton
    
    [userDefaults setObject:self.emailField.text forKey:ksettingsEmail ];
    [userDefaults setObject:self.passwordField.text forKey:ksettingsPassword];
    
    [userDefaults synchronize];
}

-(void)loadSettings {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults]; //singleton
    
    self.emailField.text = [userDefaults objectForKey:ksettingsEmail];
    self.passwordField.text = [userDefaults objectForKey:ksettingsPassword];
    
    [userDefaults synchronize];

}

# pragma mark - Actions

//- (IBAction)pressLogOut:(id)sender {
//    
//}




- (IBAction)actionTextChanged:(id)sender {
    
    [self saveSettings];
}

- (IBAction)Done:(id)sender {
     [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)pressLogout:(id)sender {
    
  
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil         message:@"my message" delegate:nil cancelButtonTitle:@"ok"         otherButtonTitles:@"set",nil];
//
//    [obj alertView:alertView clickedButtonAtIndex:0];
    
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    [userCache setBool:false forKey:@"isAuth"];
    [userCache setBool:false forKey:@"isApproved"];
    [userCache synchronize];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Settings screen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"Logout button pressed"
                                                           label:nil
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
    
                AUTHViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Chill.AuthViewController"];
                [self presentViewController:vc animated:NO completion:nil];
}
//    UIAlertView* finalCheck = [[UIAlertView alloc]
//                               initWithTitle:@"Exit from Chill"
//                               message:@"Are You sure?"
//                               delegate:self
//                               cancelButtonTitle:@"Yes"
//                               otherButtonTitles:@"Cancel",nil];
//    
//    [finalCheck show];
//    
//    
//    
//    
//}
//
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    CHLFriendsListViewController* obj = [[CHLFriendsListViewController alloc] init];
//    switch (buttonIndex) {
//        case 0:
//        {
//            NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
//            _locations = nil;
//            [obj.tableView reloadData];
//            [userCache setBool:false forKey:@"isAuth"];
//            [userCache setBool:false forKey:@"isApproved"];
//            [userCache synchronize];
//            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//            [currentInstallation removeObject:[NSString stringWithFormat:@"us%@",[userCache valueForKey:@"id_user"]] forKey:@"channels"];
//            [currentInstallation saveInBackground];
//            AUTHViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Chill.AuthViewController"];
//            [self presentViewController:vc animated:NO completion:nil];
//            
//        }
//            
//        case 1:
//        {
//            break;
//        }
//            
//        default:
//            break;
//    }
//    
//}



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
