//
//  PromoViewController.m
//  Chill
//
//  Created by Тареев Григорий & Михаил Луцкий on 08.01.15.
//  Copyright (c) 2015 Chill. All rights reserved.
//

#import "PromoViewController.h"
#import "Reachability.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"

@interface PromoViewController (){
    NSMutableArray *json;
    Reachability *internetReachableFoo;
}

@end

@implementation PromoViewController
- (BOOL)connected
{
    return [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(willShowKeyboard) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(willHideKeyboard) name:UIKeyboardWillHideNotification object:nil];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Promocode screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
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
    [_promoField resignFirstResponder];
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
    [_promoField resignFirstResponder];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)go:(id)sender {
    if (![_promoField.text isEqualToString:@""] ){
        if (![self connected]) {
            [self conRefused];
        }
        else {
            NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];

            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://api.iamchill.co/v1/promo_codes/index"]]];
            //[request setValue:@"Chill" forHTTPHeaderField:@"User-Agent"];
            [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];

            [request setHTTPMethod:@"POST"];
            
            NSURLResponse *response = nil;
            NSError *error = nil;
            NSString *postString = [NSString stringWithFormat:@"id_user=%@&code=%@",[userCache valueForKey:@"id_user"], _promoField.text];
            
            //[request setValue:[NSString
            //                   stringWithFormat:@"%lu", (unsigned long)[postString length]]
            //forHTTPHeaderField:@"Content-length"];
            
            [request setHTTPBody:[postString
                                  dataUsingEncoding:NSUTF8StringEncoding]];
            json = [NSJSONSerialization JSONObjectWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] options:NSJSONReadingMutableContainers error:&error];
            
            if ([[json valueForKey:@"status"] isEqualToString:@"failed"]){
                [self errorShow:@"It seems that the entered code is invalid or It has already been used."];
            }
            else if ([[json valueForKey:@"status"] isEqualToString:@"success"]) {
                [userCache setBool:true forKey:@"isApproved"];
                [userCache synchronize];
               
                
                [self performSegueWithIdentifier:@"AuthCompleteViewController1" sender:self];
                
                //[self dismissViewControllerAnimated:YES completion:nil];
                //[self.navigationController popViewControllerAnimated:YES];
            }
            
        }
    }
    else{
        [self errorShow:@"Fill in all fields"];
    }
}

- (IBAction)goback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}
@end
