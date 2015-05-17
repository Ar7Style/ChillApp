//
//  CHLSearchViewController.m
//  Chill
//
//  Created by Тареев Григорий & Михаил Луцкий on 13.12.14.
//  Copyright (c) 2015 Mikhail Loutskiy. All rights reserved.
//

#import "CHLSearchViewController.h"
#import "UIColor+ChillColors.h"
#import "Reachability.h"
#import <Parse/Parse.h>
#import "JSONLoader.h"
#import "SearchJSON.h"
#import "MBProgressHUD.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"
@interface CHLSearchViewController () <MBProgressHUDDelegate>
{
    NSInteger friendUserId;
    MBProgressHUD *HUD;
}

@property(nonatomic, strong) UIView *invitationView;

@end
NSMutableData *mutData;

@implementation CHLSearchViewController
{
    NSArray *_locations;
}

- (BOOL)connected
{
    return [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationController.view.layer.cornerRadius=6;
    self.navigationController.view.clipsToBounds=YES;
    self.tableView.tableFooterView = [UIView new];
    self.navigationController.navigationBar.barTintColor = [UIColor chillMintColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    _searchBar.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.invitationView) {
        [self addInvitationView];
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Contact search screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)addInvitationView {
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    if ([userCache integerForKey:@"Available invites number"] != 0) {
        self.invitationView = [[UIView alloc] initWithFrame:self.tableView.bounds];
        self.invitationView.userInteractionEnabled = NO;
        
        NSArray *friendsAmountStrings = @[@"1 more friend", @"2 more friends", @"3 friends"];
        NSString *chosenFriendsAmountString = friendsAmountStrings[[userCache integerForKey:@"Available invites number"] - 1];
        UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.35 * self.invitationView.frame.size.height, self.invitationView.frame.size.width, 70)];
        mainLabel.text = [NSString stringWithFormat:@"Help %@\nto get Chill", chosenFriendsAmountString];
        mainLabel.textAlignment = NSTextAlignmentCenter;
        mainLabel.textColor = [UIColor chillMintColor];
        mainLabel.font = [UIFont boldSystemFontOfSize:26];
        mainLabel.numberOfLines = 2;
        [self.invitationView addSubview:mainLabel];
        
        UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.35 * self.invitationView.frame.size.height + 70, self.invitationView.frame.size.width, 70)];
        subLabel.text = @"or add the ones\nalready Chilling";
        subLabel.textAlignment = NSTextAlignmentCenter;
        subLabel.textColor = [UIColor chillDarkGrayColor];
        subLabel.font = [UIFont systemFontOfSize:20];
        subLabel.numberOfLines = 2;
        [self.invitationView addSubview:subLabel];
        
        [self.tableView setBackgroundView:self.invitationView];
    }
}

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    //remaining Code'll go here
    UIButton *cancelButton;
    UIView *topView = _searchBar.subviews[0];
    for (UIView *subView in topView.subviews)
    {
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")])
        {
            cancelButton = (UIButton*)subView;
        }
    }
    if (cancelButton) {
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar resignFirstResponder];
    self.tableView.scrollEnabled=YES;
    self.tableView.allowsSelection=YES;
    //This'll Hide The cancelButton with Animation
    [searchBar setShowsCancelButton:NO animated:YES];
    //remaining Code'll go here
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (![self connected])
    {
        [self conRefused];
    }
    else
    {
        self.invitationView.hidden = YES;
        NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            _locations = [[[JSONLoader alloc] init] locationsFromJSONFile:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://api.iamchill.co/v1/search/index/id_user/%@/login/%@", [userCache valueForKey:@"id_user"], searchBar.text]] typeJSON:@"Search"];
            NSLog(@"http://api.iamchill.co/v1/search/index/id_user/%@/login/%@", [userCache valueForKey:@"id_user"], searchBar.text);
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        });

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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _locations.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    SearchJSON *location = [_locations objectAtIndex:indexPath.row];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    UILabel *nameLabel = (UILabel*) [cell viewWithTag:100];
    //nameLabel.text = location.name;
    if (![location.name isKindOfClass:[NSNull class]])
    {
        nameLabel.text = location.name;
    }
    else nameLabel.text = location.login;


    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchJSON *location = [_locations objectAtIndex:indexPath.row];
    if ([location.approved integerValue] == 0) {
        NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
        NSInteger currentInvitesNumber = [userCache integerForKey:@"Available invites number"];
        
        if (currentInvitesNumber != 0) {
            NSString *alertMessage = [NSString stringWithFormat:@"Do you really want to spend one of your invites to approve %@ in Chill?", location.name];
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Hey"
                                                                           message:alertMessage
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* declineAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel
                                                                  handler:^(UIAlertAction * action) {}];
            
            UIAlertAction* approveUserAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          [self addFriendFromIndex:indexPath.row];
                                                                          [userCache setInteger:currentInvitesNumber - 1 forKey:@"Available invites number"];
                                                                      }];
            
            [alert addAction:declineAction];
            [alert addAction:approveUserAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Sorry"
                                                                           message:@"You've already spended all your invites."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
            [alert addAction:okayAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    
    else {
        [self addFriendFromIndex:indexPath.row];
    }
}

- (void)addFriendFromIndex:(NSInteger)index {
    NSMutableURLRequest *request =
    [[NSMutableURLRequest alloc] initWithURL:
     [NSURL URLWithString:@"http://api.iamchill.co/v1/contacts/index/"]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    SearchJSON *location = [_locations objectAtIndex:index];
    friendUserId = [location.id_user integerValue];
    NSString *postString = [NSString stringWithFormat:@"id_user=%@&id_contact=%ld",[userCache valueForKey:@"id_user"],(long)friendUserId];
    
    [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection)
    {
        mutData = [NSMutableData data];
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Contact search screen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"New contact added"
                                                           label:nil
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *str = [[NSString alloc] initWithData:mutData encoding:NSUTF8StringEncoding];
    if (![str isEqualToString:@"{\"status\":\"failed\",\"error\":\"User exists.\"}"]){ //Условие
        NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
        NSString *message = [NSString stringWithFormat:@"%@ wants to Chill with You!",[userCache valueForKey:@"name"]];
        NSDictionary *data = @{
                               @"alert": message,
                               @"sound": @"default",
                               @"badge" : @"Increment",
                               @"type": @"NewUser"
                               };
        PFPush *push = [[PFPush alloc] init];
        [push setChannel:[NSString stringWithFormat:@"us%li",(long)friendUserId]]; //Set channel by user friend id
        [push setData:data];
        [push sendPushInBackground];
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        
        // Set custom view mode
        HUD.mode = MBProgressHUDModeCustomView;
        
        HUD.delegate = self;
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
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}
-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer
{
   [self resignFirstResponder];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [mutData setLength:0];
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mutData appendData:data];
}


- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
@end
