//
//  APPROVEDViewController.m
//  Chill
//
//  Created by Тареев Григорий & Михаил Луцкий on 17.11.14.
//  Copyright (c) 2014 Victor Shamanov. All rights reserved.
//

#import "APPROVEDViewController.h"
#import <Social/Social.h>
#import <Parse/Parse.h>
#import "CHLFriendsListViewController.h"
#import "Reachability.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"

@interface APPROVEDViewController() <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    NSMutableArray *json;
    Reachability *internetReachableFoo;
    NSTimer *timer;
}
@property (weak, nonatomic) IBOutlet UIButton *promoButton;

@end

@implementation APPROVEDViewController
- (BOOL)connected
{
    return [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _promoButton.enabled = NO;
    _contentView.image = [UIImage imageNamed:@"Waitlist"];
    _contentView.contentMode = UIViewContentModeScaleAspectFit;
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated{
   // self.navigationController.view.layer.cornerRadius=6;
    //[self targetMethod:nil];
    self.navigationController.view.clipsToBounds=YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(targetMethod:)
                                   userInfo:nil
                                    repeats:YES];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Selfie away screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (IBAction)takeASelfieButtonPressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (void) targetMethod: (id)sender {
    if (![self connected]) {
        [self conRefused];
    }
    else {
        NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://api.iamchill.co/v1/users/index/id_user/%@",[userCache valueForKey:@"id_user"]]]];
        //[request setValue:@"Chill" forHTTPHeaderField:@"User-Agent"];
        [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
        NSURLResponse *response = nil;
        NSError *error = nil;
        
        json = [NSJSONSerialization JSONObjectWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] options:NSJSONReadingMutableContainers error:&error];
        if ([[json valueForKey:@"status"] isEqualToString:@"failed"])
        {
            //[self errorShow:@"Похоже, что введенный логин или пароль неверный"];
        }
        else if ([[json valueForKey:@"status"] isEqualToString:@"success"]) {
    
            [userCache setValue:[[[json valueForKey:@"response"] valueForKey:@"approved"] componentsJoinedByString:@""] forKey:@"approved"];
            [userCache synchronize];

       
            
           if ( [[userCache valueForKey:@"approved"] isEqualToString:@"1"])
           {
               
               [userCache setBool:true forKey:@"isApproved"];
               [userCache synchronize];
               
               NSString *message = [NSString stringWithFormat:@"Wohoo! You've been approved, check the app out!🎉✌️👇"];
               NSDictionary *data = @{
                                      @"alert": message,
                                      @"type": @"Location",
                                      @"sound": @"default",
                                      @"badge" : @1,//@"Increment",
                                      @"fromUserId": [userCache valueForKey:@"id_user"]
                                      };
               PFPush *push = [[PFPush alloc] init];
               
               [push setChannel:[NSString stringWithFormat:@"us%li",(long)[userCache valueForKey:@"id_user"]]];
               [push setData:data];
               [push sendPushInBackground];
               
               UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
               
               UIViewController *tutorialViewController = (UIViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"TutorialViewController"];
               
                   [self.navigationController pushViewController:tutorialViewController animated:YES];
            
               [timer invalidate];
               timer = nil;
               
           }
            
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [timer invalidate];
    timer = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)showTwitterViewControllerWithImage:(UIImage *)image {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
        NSString *userName = [userCache valueForKey:@"login_user"];
        [userCache setValue:[[[json valueForKey:@"response"] valueForKey:@"approved"] componentsJoinedByString:@""] forKey:@"approved"];
        [userCache synchronize];
        

        SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *tweetString = [NSString stringWithFormat:@"Excited to check out @app_chill #%@ #iamchill", userName];
        [twitterViewController setInitialText:tweetString];
        [twitterViewController addImage:image];
        [self presentViewController:twitterViewController animated:YES completion:nil];
        [timer invalidate];
        timer = nil;
    }
    else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Sorry"
                                                                       message:@"Log in your Twitter account first"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {}];
        [alert addAction:okayAction];
        [self presentViewController:alert animated:YES completion:nil];
        [timer invalidate];
        timer = nil;
    }
}

#pragma mark - imagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *takenImage = info[UIImagePickerControllerOriginalImage];
    [self showTwitterViewControllerWithImage:takenImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end