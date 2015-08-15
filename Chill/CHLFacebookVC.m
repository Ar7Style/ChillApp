//
//  CHLFacebookVC.m
//  Chill
//
//  Created by Ivan Grachev on 7/17/15.
//  Copyright (c) 2015 Chill. All rights reserved.
//

#import "CHLFacebookVC.h"
#import "CHLFriendCell.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "CHLFacebookVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface CHLFacebookVC () <MBProgressHUDDelegate, FBSDKLoginButtonDelegate> {
    NSMutableDictionary *jsonResponse;
    NSMutableData *receivedData;
    MBProgressHUD *HUD;
}

@property(nonatomic, strong) FBSDKLoginButton *logInButton;
@property(nonatomic, strong) NSMutableArray *facebookIDs;
@property(nonatomic, strong) NSMutableArray *facebookDisplayNames;
@property(nonatomic, strong) NSMutableArray *chillUsernames;
@property(nonatomic, strong) NSMutableArray *chillIDs;
@property(nonatomic, strong) NSMutableArray *chillRegisteredFacebookIDs;

@end

@implementation CHLFacebookVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.facebookIDs = [[NSMutableArray alloc] init];
    self.facebookDisplayNames = [[NSMutableArray alloc] init];
    self.chillUsernames = [[NSMutableArray alloc] init];
    self.chillIDs = [[NSMutableArray alloc] init];
    self.chillRegisteredFacebookIDs = [[NSMutableArray alloc] init];
    
    if ([FBSDKAccessToken currentAccessToken] == nil) {
        self.logInButton = [[FBSDKLoginButton alloc] init];
        self.logInButton.delegate = self;
        self.logInButton.readPermissions = @[@"public_profile", @"user_friends"];
        self.logInButton.center = self.view.center;
        [self.view addSubview:self.logInButton];
    }
    else {
        [self startSearchingFacebookFriends];
//        NSLog(@"APP ID");
//        NSLog([[FBSDKAccessToken currentAccessToken] appID]);
    }
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if (!result.isCancelled) {
        [self sendFacebookIDToBackend];
    }
    else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Sorry"
                                                                       message:@"Can't log in Facebook"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {}];
        [alert addAction:okayAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    //for conformance sake
}

- (void)showLoadingState {
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.tableView.frame];
    UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    progressView.center = backgroundView.center;
    [progressView startAnimating];
    [backgroundView addSubview:progressView];
    self.tableView.backgroundView = backgroundView;
}

- (void)startSearchingFacebookFriends {
    [self.logInButton removeFromSuperview];
    self.logInButton = nil;
    [self showLoadingState];
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:@{} HTTPMethod:@"GET"];
    __block CHLFacebookVC *weakSelf = self;
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        for (NSDictionary *facebookUser in (NSDictionary *)result[@"data"]) {
            NSString *facebookDisplayName = facebookUser[@"name"];
            NSString *facebookID = facebookUser[@"id"];
            if (facebookID != nil && facebookDisplayName != nil) {
                [weakSelf.facebookDisplayNames addObject:facebookDisplayName];
                [weakSelf.facebookIDs addObject:facebookID];
            }
        }
        [weakSelf fetchFacebookFriendsInChill];
    }];
}

- (void)sendFacebookIDToBackend {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://api.iamchill.co/v2/users/update/"]]];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    
    [request setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    
    [request setHTTPMethod:@"POST"];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    
    NSString *facebookID = [[FBSDKAccessToken currentAccessToken] userID];
    NSString *postString = [NSString stringWithFormat:@"id_user=%@&id_facebook=%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"id_user"], facebookID];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (data != nil) {
        jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    }
    if([response statusCode] != 200){
        NSLog(@"Error getting, HTTP status code %li", (long)[response statusCode]);
    }
    [self startSearchingFacebookFriends];
}

- (void)fetchFacebookFriendsInChill {
    NSString* str_facebook_IDs = [self.facebookIDs componentsJoinedByString:@"-"];
    
    NSString* url = [NSString stringWithFormat:@"http://api.iamchill.co/v2/social/facebook/id_user/%@/id_contacts_facebook/%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"id_user"], str_facebook_IDs];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    [request setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse* response = nil;
    
    jsonResponse = [NSJSONSerialization JSONObjectWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] options:NSJSONReadingMutableContainers error:&error][@"response"];
    
    if (((NSArray *)jsonResponse[@"chill"]).count != 0) {
        for (NSDictionary *subJSON in jsonResponse[@"chill"][0]) {
            NSString *chillID = subJSON[@"id"];
            NSString *facebookID = subJSON[@"id_facebook"];
            NSString *chillLogin = subJSON[@"login"];
            if (chillID != nil && facebookID != nil && chillLogin != nil) {
                [self.chillIDs addObject:chillID];
                [self.chillRegisteredFacebookIDs addObject:facebookID];
                [self.chillUsernames addObject:chillLogin];
            }
        }
    }
    
    if([response statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %li", url, (long)[response statusCode]);
    }
    else {
        self.tableView.backgroundView = nil;
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chillUsernames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHLFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCell"];
    cell.senderLabel.text = self.chillUsernames[indexPath.row];
    NSUInteger facebookIndex = [self.facebookIDs indexOfObject:self.chillRegisteredFacebookIDs[indexPath.row]];
    cell.lastChilTitleLabel.text = [NSString stringWithFormat:@"%@", self.facebookDisplayNames[facebookIndex]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableURLRequest *request =
    [[NSMutableURLRequest alloc] initWithURL:
     [NSURL URLWithString:@"http://api.iamchill.co/v2/contacts/index/"]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"]; [request setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    NSString *postString = [NSString stringWithFormat:@"id_user=%@&id_contact=%@",[userCache valueForKey:@"id_user"], self.chillIDs[indexPath.row]];
    
    [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    __block CHLFacebookVC *weakSelf = self;
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                         [weakSelf addFriendCallbackForFriend:weakSelf.chillIDs[indexPath.row] data:data withWeakSelf:weakSelf];
                                                                     }];
    [dataTask resume];
}

- (void)addFriendCallbackForFriend:(NSString *)friend data:(NSData *)data withWeakSelf:(CHLFacebookVC *)weakSelf
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (![str isEqualToString:@"{\"status\":\"failed\",\"error\":\"User exists.\"}"]){ //Условие
            NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
            NSString *message = [NSString stringWithFormat:@"%@ wants to Chill with You!",[userCache valueForKey:@"name"]];
            NSDictionary *pushData = @{
                                       @"alert": message,
                                       @"sound": @"default",
                                       @"badge" : @1,
                                       @"type": @"NewUser"
                                       };
            PFPush *push = [[PFPush alloc] init];
            [push setChannel:[NSString stringWithFormat:@"us%@",friend]]; //Set channel by user friend id
            [push setData:pushData];
            [push sendPushInBackground];
            HUD = [[MBProgressHUD alloc] initWithView:weakSelf.navigationController.view];
            [weakSelf.navigationController.view addSubview:HUD];
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            
            // Set custom view mode
            HUD.mode = MBProgressHUDModeCustomView;
            
            HUD.delegate = weakSelf;
            HUD.labelText = @"Completed";
            
            [HUD show:YES];
            [HUD hide:YES afterDelay:2];
        }
        else
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                           message:@"User is already connected with you"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {}];
            [alert addAction:okayAction];
            [weakSelf presentViewController:alert animated:YES completion:nil];
        }
    });
}

@end
