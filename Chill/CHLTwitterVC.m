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

@interface CHLTwitterVC () {
    NSMutableArray *json;

}

@property(nonatomic, strong) TWTRSession *twitterSession;
@property(nonatomic, strong) TWTRLogInButton *logInButton;
@property(nonatomic, strong) NSMutableArray *toInviteIDs;
@property(nonatomic, strong) NSMutableArray *toInviteNicknames;
@property(nonatomic, strong) NSMutableArray *toInviteDisplayNames;

@end

@implementation CHLTwitterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.toInviteIDs = [[NSMutableArray alloc] init];
    self.toInviteNicknames = [[NSMutableArray alloc] init];
    self.toInviteDisplayNames = [[NSMutableArray alloc] init];
    if ([[Twitter sharedInstance] session] == nil) {
        __block CHLTwitterVC *weakSelf = self;
        self.logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession* session, NSError* error) {
            if (session) {
                weakSelf.twitterSession = [[Twitter sharedInstance] session];
                [weakSelf sendTwitterIDToBackend];
                [weakSelf startSearchingTwitterFriends];
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


- (void)startSearchingTwitterFriends {
    [self.logInButton removeFromSuperview];
    self.logInButton = nil;
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                });
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
    NSLog(@"MASSIV IDIWNIKOV: %@", self.toInviteIDs);
    //TODO: implement it
    NSString* str_twitter_IDs = [self.toInviteIDs componentsJoinedByString:@"??"];
    
    NSLog(@"Stroka s twitterID: %@", str_twitter_IDs);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://api.iamchill.co/v1/search/twitter/"]]];
    //                [request setValue:@"Chill" forHTTPHeaderField:@"User-Agent"];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    
    [request setHTTPMethod:@"POST"];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSString *postString = [NSString stringWithFormat:@"id_user=%@&str_twitter_id=%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"id_user"],  str_twitter_IDs];
    
        [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    json = [NSJSONSerialization JSONObjectWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] options:NSJSONReadingMutableContainers error:&error];
    
    
    NSLog(@"REQUEST's STATUS: %@", json);
    
    if ([[json valueForKey:@"status"] isEqualToString:@"failed"]){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Sorry"
                                                                       message:@"Can't find Your friends in Twitter"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {}];
        [alert addAction:okayAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else if ([[json valueForKey:@"status"] isEqualToString:@"success"]) {
        NSLog(@"SUCCESS TWITTER RESPONCE");
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.toInviteIDs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHLFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InviteCell"];
    cell.senderLabel.text = self.toInviteDisplayNames[indexPath.row];
    cell.lastChilTitleLabel.text = [NSString stringWithFormat:@"@%@", self.toInviteNicknames[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    
    NSString *tweetText = [NSString stringWithFormat:@"Hey @%@, check out Chill, the only wearable messenger that finally makes sense: iamchill.co", self.toInviteNicknames[indexPath.row]];
    [composer setText:tweetText];
    [composer showFromViewController:self completion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Tweet composition cancelled");
            [self sendTwitterIDToBackend];

        }
        else {
            NSLog(@"Sending Tweet!");
        }
    }];
}

@end
