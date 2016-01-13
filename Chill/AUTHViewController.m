//
//  AUTHViewController.m
//  Chill
//
//  Created by Тареев Григорий & Михаил Луцкий on 16.11.14.
//  Copyright (c) 2014 Chill. All rights reserved.
//

#import "AUTHViewController.h"
#import "APPROVEDViewController.h"
#import "CHLSettingsViewController.h"
#import <Parse/Parse.h>
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"
#import <PebbleKit/PebbleKit.h>
#import "UIViewController+KeyboardAnimation.h"
#import <AFNetworking/AFNetworking.h>
#import "UserCache.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "SCLAlertView.h"
#import "UIColor+ChillColors.h"


@interface AUTHViewController () <WCSessionDelegate>
@property (strong, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottom;

@property (weak, nonatomic) IBOutlet UIButton *promocodeButton;
@end

@implementation AUTHViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
}
-  (void)viewDidAppear:(BOOL)animated {
    self.navigationController.view.clipsToBounds=YES;
}

- (IBAction)promocodeButtonTapped:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.customViewColor = [UIColor chillMintColor];
    UITextField *textField = [alert addTextField:@"Enter promocode"];
    
    [alert addButton:@"Submit" actionBlock:^(void) {
        NSLog(@"Text value: %@", textField.text);
                    
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
            NSDictionary *parameters = @{@"id_user": _loginField1.text, @"password":_passwordField1.text};
        
            [manager GET:@"http://api.iamchill.co/v2/users/index" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([[responseObject valueForKey:@"status"] isEqualToString:@"failed"]){
                [self errorShow:@"It seems that the entered username or password is incorrect"];
            }
            else if ([[responseObject valueForKey:@"status"] isEqualToString:@"success"]) {
                
            }
            
        }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self conRefused];
            NSLog(@"Error: %@", error);
        }];
    }];
        
    [alert showEdit:self title:@"Get features" subTitle:@"Enter the promocode" closeButtonTitle:@"Close" duration:0.0f];
}

-(void)viewWillAppear:(BOOL)animated {
    __weak __typeof(self) weakSelf = self;

    [self an_subscribeKeyboardWithAnimations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {
        __typeof__(self) strongSelf = weakSelf;
        self.constraintBottom.constant = isShowing ?  CGRectGetHeight(keyboardRect) : 0;
        [self.view layoutIfNeeded];
    } completion:nil];
    [self.view layoutIfNeeded];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self an_unsubscribeKeyboard];
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
- (void)backgroundTouchedHideKeyboard:(id)sender
{
    [_loginField1 resignFirstResponder];
    [_passwordField1 resignFirstResponder];
}


-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {
    [_loginField1 resignFirstResponder];
    [_passwordField1 resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)nextBut:(id)sender {
    
    [_loginField1.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [_passwordField1.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];


    if (![_loginField1.text isEqualToString:@""] && ![_passwordField1.text isEqualToString:@""]){
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
        NSDictionary *parameters = @{@"login": _loginField1.text, @"password":_passwordField1.text};
        [manager POST:@"http://api.iamchill.co/v2/users/index" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([[responseObject valueForKey:@"status"] isEqualToString:@"failed"]){
                [self errorShow:@"It seems that the entered username or password is incorrect"];
            }
            else if ([[responseObject valueForKey:@"status"] isEqualToString:@"success"]) {
                [NSUserDefaults changeAuth:true];
                [NSUserDefaults setValue:[[responseObject valueForKey:@"response"] valueForKey:@"id_user"] forKey:@"id_user"];
                [NSUserDefaults setValue:_loginField1.text forKey:@"login_user"];
                [NSUserDefaults setValue:[[responseObject valueForKey:@"response"] valueForKey:@"token"] forKey:@"token"];
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation addUniqueObject:[NSString stringWithFormat:@"us%@",[NSUserDefaults userID]] forKey:@"channels"];
                [currentInstallation saveInBackground];
                
                [self setupGAUserID: [NSUserDefaults userID]];

                AFHTTPRequestOperationManager *manager2 = [AFHTTPRequestOperationManager manager];
                manager2.responseSerializer = [AFJSONResponseSerializer serializer];
                manager2.requestSerializer = [AFJSONRequestSerializer serializer];
                [manager2.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
                [manager2.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
                [manager2 GET:[NSString stringWithFormat:@"http://api.iamchill.co/v2/users/index/id_user/%@",[NSUserDefaults userID]] parameters:nil success:^(AFHTTPRequestOperation *operation2, id responseObject2) {
                    if ([[responseObject2 valueForKey:@"status"] isEqualToString:@"success"])
                    {
                        
                        [NSUserDefaults setValue:[[[responseObject2 valueForKey:@"response"] valueForKey:@"name"]componentsJoinedByString:@""] forKey:@"name"];
                        [NSUserDefaults setValue:[[[responseObject2 valueForKey:@"response"] valueForKey:@"email"]componentsJoinedByString:@""] forKey:@"email"];
                        CHLSettingsViewController *settingsVC = [[CHLSettingsViewController alloc]init];
                        
                        settingsVC.email = [responseObject2 valueForKey:@"email"];
                        [NSUserDefaults setValue:[[[responseObject2 valueForKey:@"response"] valueForKey:@"hash"]componentsJoinedByString:@""] forKey:@"hash"];
                        [NSUserDefaults setValue:[[[responseObject2 valueForKey:@"response"] valueForKey:@"key"]componentsJoinedByString:@""] forKey:@"key"];
                        [NSUserDefaults setValue:[[[responseObject2 valueForKey:@"response"] valueForKey:@"date_reg"]componentsJoinedByString:@""] forKey:@"date_reg"];
                        [NSUserDefaults setValue:[[[responseObject2 valueForKey:@"response"] valueForKey:@"approved"] componentsJoinedByString:@""] forKey:@"approved"];
                        [NSUserDefaults setValue:[[[responseObject2 valueForKey:@"response"] valueForKey:@"token"] componentsJoinedByString:@""] forKey:@"token1"];
                        
                            [NSUserDefaults changeAprooved:true];
                        
                        WCSession *session = [WCSession defaultSession];
                        NSError *error;
                        
                        [session updateApplicationContext:@{@"userID": [NSUserDefaults userID], @"token":[NSUserDefaults userToken], @"isAuth":@"true", @"isApproved": @"true"} error:&error];
                        if ([[userCache valueForKey:@"isEntry"] isEqualToString:@"0"])
                            [self performSegueWithIdentifier:@"toTutorialViewController" sender:self];
                        else
                        {
                            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                            
                            UIViewController *friendListViewController = (UIViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"CHLFriendsListViewController"];
                            
                            
                            [self dismissViewControllerAnimated:YES completion:nil];
                            [self.navigationController pushViewController:friendListViewController animated:YES];
                            
//                            [self dismissViewControllerAnimated:YES completion:nil];
//                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    }

                    NSLog(@"JSON: %@", responseObject2);
                } failure:^(AFHTTPRequestOperation *operation2, NSError *error2) {
                    NSLog(@"Error: %@", error2);
                    [self errorShow:@"Please, check Your internet connection"];
                }];
            }
            NSLog(@"JSON: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self conRefused];
            NSLog(@"Error: %@", error);
        }];
    }
    else
    {
        [self errorShow:@"Fill in all fields"];
    }
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

@end
