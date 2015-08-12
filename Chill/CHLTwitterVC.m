//
//  CHLTwitterVC.m
//  Chill
//
//  Created by Ivan Grachev on 7/17/15.
//  Copyright (c) 2015 Victor Shamanov. All rights reserved.
//

#import "CHLTwitterVC.h"
#import <TwitterKit/TwitterKit.h>
#import "CHLFriendCell.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>

@interface CHLTwitterVC () <MBProgressHUDDelegate> {
    NSMutableDictionary *jsonResponse;
    NSMutableData *receivedData;
    MBProgressHUD *HUD;
}

@property(nonatomic, strong) TWTRSession *twitterSession;
@property(nonatomic, strong) TWTRLogInButton *logInButton;
@property(nonatomic, strong) NSMutableArray *toInviteIDs;
@property(nonatomic, strong) NSMutableArray *returnedFromChillToInviteTwitterIDs;
@property(nonatomic, strong) NSMutableArray *toInviteNicknames;
@property(nonatomic, strong) NSMutableArray *toInviteDisplayNames;
@property(nonatomic, strong) NSMutableArray *chillUsernames;
@property(nonatomic, strong) NSMutableArray *chillIDs;
@property(nonatomic, strong) NSMutableArray *chillRegisteredTwitterIDs;

@end

@implementation CHLTwitterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.toInviteIDs = [[NSMutableArray alloc] init];
    self.toInviteNicknames = [[NSMutableArray alloc] init];
    self.toInviteDisplayNames = [[NSMutableArray alloc] init];
    self.chillUsernames = [[NSMutableArray alloc] init];
    self.chillIDs = [[NSMutableArray alloc] init];
    self.returnedFromChillToInviteTwitterIDs = [[NSMutableArray alloc] init];
    self.chillRegisteredTwitterIDs = [[NSMutableArray alloc] init];
    
    if ([[Twitter sharedInstance] session] == nil) {
        __block CHLTwitterVC *weakSelf = self;
        self.logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession* session, NSError* error) {
            if (session) {
                weakSelf.twitterSession = [[Twitter sharedInstance] session];
                [weakSelf sendTwitterIDToBackend];
            } else {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Sorry"
                                                                               message:@"Can't log in Twitter"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {}];
                [alert addAction:okayAction];
                [weakSelf presentViewController:alert animated:YES completion:nil];
            }
        }];
        self.logInButton.center = self.view.center;
        [self.view addSubview:self.logInButton];
    }
    else {
        self.twitterSession = [[Twitter sharedInstance] session];
        [self startSearchingTwitterFriends];
    }
}

- (void)showLoadingState {
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.tableView.frame];
    UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    progressView.center = backgroundView.center;
    [progressView startAnimating];
    [backgroundView addSubview:progressView];
    self.tableView.backgroundView = backgroundView;
}

- (void)startSearchingTwitterFriends {
    [self.logInButton removeFromSuperview];
    self.logInButton = nil;
    [self showLoadingState];
    NSString *friendsEndpoint = @"https://api.twitter.com/1.1/friends/list.json";
    NSDictionary *params = @{@"user_id" : self.twitterSession.userID, @"count" : @"200"};
    NSError *clientError;
    
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:friendsEndpoint parameters:params error:&clientError];
    
    if (request) {
        __block CHLTwitterVC *weakSelf = self;
        [[[Twitter sharedInstance] APIClient] sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                NSError *jsonError;
                NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError][@"users"];
                for (NSDictionary *subJSON in json) {
                    NSString *idString = subJSON[@"id_str"];
                    NSString *nickname = subJSON[@"screen_name"];
                    NSString *displayName = subJSON[@"name"];
                    if (idString != nil && nickname != nil && displayName != nil) {
                        [weakSelf.toInviteDisplayNames addObject:displayName];
                        [weakSelf.toInviteIDs addObject:idString];
                        [weakSelf.toInviteNicknames addObject:nickname];
                    }
                }
                [weakSelf fetchTwitterFriendsInChill];
            }
            else {
                NSLog(@"Error: %@", connectionError);
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
}

- (void)sendTwitterIDToBackend {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://api.iamchill.co/v2/users/update/"]]];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    
    [request setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    
    [request setHTTPMethod:@"POST"];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSString *postString = [NSString stringWithFormat:@"id_user=%@&id_twitter=%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"id_user"], self.twitterSession.userID];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    jsonResponse = [NSJSONSerialization JSONObjectWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"Request's data: %@", jsonResponse);
    if([response statusCode] != 200){
        NSLog(@"Error getting, HTTP status code %li", (long)[response statusCode]);
    }
    [self startSearchingTwitterFriends];
}

- (void)fetchTwitterFriendsInChill {
    NSString* str_twitter_IDs = [self.toInviteIDs componentsJoinedByString:@"-"];
    
    NSString* url = [NSString stringWithFormat:@"http://api.iamchill.co/v2/social/twitter/id_user/%@/id_contacts_twitter/%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"id_user"], str_twitter_IDs];
    
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
            NSString *twitterID = subJSON[@"id_twitter"];
            NSString *chillLogin = subJSON[@"login"];
            if (chillID != nil && twitterID != nil && chillLogin != nil) {
                [self.chillIDs addObject:chillID];
                [self.chillRegisteredTwitterIDs addObject:twitterID];
                [self.chillUsernames addObject:chillLogin];
            }
        }
    }
    
    for (NSString *twitterID in jsonResponse[@"twitter"]) {
        if (twitterID != nil) {
            [self.returnedFromChillToInviteTwitterIDs addObject:twitterID];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.chillUsernames count];
    }
    else {
        return [self.returnedFromChillToInviteTwitterIDs count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CHLFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCell"];
        cell.senderLabel.text = self.chillUsernames[indexPath.row];
        NSUInteger twitterIndex = [self.toInviteIDs indexOfObject:self.chillRegisteredTwitterIDs[indexPath.row]];
        cell.lastChilTitleLabel.text = [NSString stringWithFormat:@"%@", self.toInviteDisplayNames[twitterIndex]];
        return cell;
    }
    else {
        CHLFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InviteCell"];
        cell.senderLabel.text = self.toInviteDisplayNames[indexPath.row];
        cell.lastChilTitleLabel.text = [NSString stringWithFormat:@"@%@", self.toInviteNicknames[indexPath.row]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSMutableURLRequest *request =
        [[NSMutableURLRequest alloc] initWithURL:
         [NSURL URLWithString:@"http://api.iamchill.co/v2/contacts/index/"]];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"]; [request setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
        
        NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
        NSString *postString = [NSString stringWithFormat:@"id_user=%@&id_contact=%@",[userCache valueForKey:@"id_user"],self.chillIDs[indexPath.row]];
        
        [request setHTTPBody:[postString
                              dataUsingEncoding:NSUTF8StringEncoding]];
        __block CHLTwitterVC *weakSelf = self;
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                             [weakSelf addFriendCallbackForFriend:weakSelf.chillIDs[indexPath.row] data:data withWeakSelf:weakSelf];
                                                                         }];
        [dataTask resume];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:true];
        TWTRComposer *composer = [[TWTRComposer alloc] init];
        
        NSString *tweetText = [NSString stringWithFormat:@"Hey @%@, сheck out Chill — a textless/voiceless communication app for wearables: iamchill.co", self.toInviteNicknames[indexPath.row]];
        [composer setText:tweetText];
        [composer showFromViewController:self completion:^(TWTRComposerResult result) {
            if (result == TWTRComposerResultCancelled) {
                NSLog(@"Tweet composition cancelled");
            }
            else {
                NSLog(@"Sending Tweet!");
            }
        }];
    }
}

- (void)addFriendCallbackForFriend:(NSString *)friend data:(NSData *)data withWeakSelf:(CHLTwitterVC *)weakSelf
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
