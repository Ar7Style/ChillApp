//
//  AUTHViewController.m
//  Chill
//
//  Created by Тареев Григорий & Михаил Луцкий on 16.11.14.
//  Copyright (c) 2014 Chill. All rights reserved.
//

#import "AUTHViewController.h"
#import "APPROVEDViewController.h"
#import "Reachability.h"
#import <Parse/Parse.h>
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"

@interface AUTHViewController (){
    NSMutableArray *json;
    Reachability *internetReachableFoo;
}
@property (strong, nonatomic) IBOutlet UIView *viewMain;
- (IBAction)GO:(id)sender;

@end

@implementation AUTHViewController
- (BOOL)connected
{
    return [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-  (void)viewDidAppear:(BOOL)animated {
   // self.navigationController.view.layer.cornerRadius=6;
    self.navigationController.view.clipsToBounds=YES;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(willShowKeyboard) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(willHideKeyboard) name:UIKeyboardWillHideNotification object:nil];
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    BOOL isApproved = [userCache boolForKey:@"isApproved"];
    BOOL isAuthComplete = [userCache boolForKey:@"isAuth"];
    if (isAuthComplete && !isApproved){
        [self performSegueWithIdentifier:@"AuthWaitingViewController" sender:self];
    }
}
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
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //Iterate through your subviews, or some other custom array of views
    for (UIView *view in self.view.subviews)
        [view resignFirstResponder];
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

    if (![_loginField1.text isEqualToString:@""] && ![_passwordField1.text isEqualToString:@""]){
        if (![self connected]) {
            [self conRefused];
        }
        else {
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://api.iamchill.co/v1/users/index"]]];
//            [request setValue:@"Chill" forHTTPHeaderField:@"User-Agent"];
            [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];

            [request setHTTPMethod:@"POST"];

            NSURLResponse *response = nil;
            NSError *error = nil;
            NSString *postString = [NSString stringWithFormat:@"login=%@&password=%@",_loginField1.text, _passwordField1.text];
            
//            [request setValue:[NSString
//                               stringWithFormat:@"%lu", (unsigned long)[postString length]]
//            forHTTPHeaderField:@"Content-length"];
            
            [request setHTTPBody:[postString
                                  dataUsingEncoding:NSUTF8StringEncoding]];
            json = [NSJSONSerialization JSONObjectWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] options:NSJSONReadingMutableContainers error:&error];
            
            NSLog(@"0");

            if ([[json valueForKey:@"status"] isEqualToString:@"failed"]){
                [self errorShow:@"It seems that the entered username or password is incorrect"];
            }
            else if ([[json valueForKey:@"status"] isEqualToString:@"success"]) {
                NSLog(@"1");

                NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
                [userCache setBool:true forKey:@"isAuth"];
                [userCache setValue:[[json valueForKey:@"response"] valueForKey:@"id_user"] forKey:@"id_user"];
                [userCache setValue:_loginField1.text forKey:@"login_user"];
                [userCache setValue:[[json valueForKey:@"response"] valueForKey:@"token"] forKey:@"token"];
                [userCache synchronize];
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation addUniqueObject:[NSString stringWithFormat:@"us%@",[userCache valueForKey:@"id_user"]] forKey:@"channels"];
                [currentInstallation saveInBackground];

                [self setupGAUserID: [userCache valueForKey:@"id_user"]];
                userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
                
                request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://api.iamchill.co/v1/users/index/id_user/%@",[userCache valueForKey:@"id_user"]]]];
                //[request setValue:@"Chill" forHTTPHeaderField:@"User-Agent"];
                [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
                response = nil;
                error = nil;
                
                json = [NSJSONSerialization JSONObjectWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] options:NSJSONReadingMutableContainers error:&error];
                if ([[json valueForKey:@"status"] isEqualToString:@"failed"])
                {
                    NSLog(@"%@", [json valueForKey:@"response"]);
                   //[self performSegueWithIdentifier:@"AuthWaitingViewController" sender:self];
                }
                else if ([[json valueForKey:@"status"] isEqualToString:@"success"])
                {
                
                    [userCache setValue:[[[json valueForKey:@"response"] valueForKey:@"name"]componentsJoinedByString:@""] forKey:@"name"];
                    [userCache setValue:[[[json valueForKey:@"response"] valueForKey:@"email"]componentsJoinedByString:@""] forKey:@"email"];
                    [userCache setValue:[[[json valueForKey:@"response"] valueForKey:@"hash"]componentsJoinedByString:@""] forKey:@"hash"];
                    [userCache setValue:[[[json valueForKey:@"response"] valueForKey:@"key"]componentsJoinedByString:@""] forKey:@"key"];
                    [userCache setValue:[[[json valueForKey:@"response"] valueForKey:@"date_reg"]componentsJoinedByString:@""] forKey:@"date_reg"];
                    [userCache setValue:[[[json valueForKey:@"response"] valueForKey:@"approved"] componentsJoinedByString:@""] forKey:@"approved"];
                    [userCache setValue:[[[json valueForKey:@"response"] valueForKey:@"token"] componentsJoinedByString:@""] forKey:@"token1"];
                    [userCache synchronize];
                    if ( [[userCache valueForKey:@"approved"] isEqualToString:@"1"]){
                        
                        [userCache setBool:true forKey:@"isApproved"];
                        [userCache synchronize];
                        [self performSegueWithIdentifier:@"toTutorialViewController" sender:self];
                     //   [self dismissViewControllerAnimated:YES completion:nil];
                    //   [self.navigationController popViewControllerAnimated:YES];
                        
                    }
                    else if ([[userCache valueForKey:@"approved"] isEqualToString:@"0"])
                    {
                        [self performSegueWithIdentifier:@"AuthWaitingViewController" sender:self];
                    }
                    
                }

            }
           
         
        }
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

- (IBAction)GO:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
