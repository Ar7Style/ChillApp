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

@interface CHLTwitterVC ()

@property(nonatomic, strong) TWTRSession *twitterSession;
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
        TWTRLogInButton* logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession* session, NSError* error) {
            if (session) {
                [weakSelf sendTwitterIDToBackend];
                [weakSelf startSearchingTwitterFriends];
                [logInButton removeFromSuperview];
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
        logInButton.center = self.view.center;
        [self.view addSubview:logInButton];
    }
    else {
        self.twitterSession = [[Twitter sharedInstance] session];
        [self startSearchingTwitterFriends];
    }
}


- (void)startSearchingTwitterFriends {
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
    //TODO: implement it
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
        }
        else {
            NSLog(@"Sending Tweet!");
        }
    }];
}

@end
