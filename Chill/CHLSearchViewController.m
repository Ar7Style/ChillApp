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

#import "SCLAlertView.h"
#import <AFNetworking/AFNetworking.h>

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"

#import "UserCache.h"


#define NUMBER_OF_STATIC_CELLS 3
#define NORMAL_HEIGHT 81
#define STATIC_CELL_HEIGHT 40

@interface CHLSearchViewController () <MBProgressHUDDelegate>
{
    NSInteger friendUserId;
    MBProgressHUD *HUD;
    int searchType;
}

@property(nonatomic) BOOL searchModeUsers;
@property(nonatomic, weak) UISegmentedControl *searchSwitch;
@property(nonatomic, weak) UIButton *facebookButton;
@property(nonatomic, weak) UIButton *twitterButton;
@property(nonatomic, weak) UIButton *shareButton;

@end
NSMutableData *mutData;

@implementation CHLSearchViewController
{
    NSArray *_locations;
    NSArray *_locationsApps;
}

- (BOOL)connected
{
    return [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable;
}

- (void)switchSearch
{
    self.searchModeUsers = !self.searchModeUsers;
    self.searchBar.placeholder = self.searchModeUsers ? @"User login for search" : @"App for search";
    [self performSearchWithQuery:self.searchBar.text];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchModeUsers = NO;
    [self switchSearch];
    
    //self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.view.clipsToBounds=YES;
    self.tableView.tableFooterView = [UIView new];
    //self.navigationController.navigationBar.barTintColor = [UIColor chillMintColor];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    _searchBar.delegate = self;
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    NSDictionary *parameters = @{@"id_user": [userCache valueForKey:@"id_user"]};
    
    [manager POST:@"http://api.iamchill.co/v2/promocodes/index" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([[responseObject valueForKey:@"status"] isEqualToString:@"failed"]){
            [self errorShow:@"It seems that the entered email or password is incorrect"];
            NSLog(@"Fail promo");
        }
        else if ([[responseObject valueForKey:@"status"] isEqualToString:@"success"]) {
            [userCache setValue:[[responseObject valueForKey:@"response"] valueForKey:@"code"] forKey:@"promocode"];
            [userCache setValue:[[responseObject valueForKey:@"response"] valueForKey:@"link"] forKey:@"link"];
            [userCache synchronize];
            NSLog(@"Promo success: %@", [userCache valueForKey:@"promocode"]);
            
        }
    }
          failure:^(AFHTTPRequestOperation *operation2, NSError *error2) {
              [self errorShow:@"Please, check Your internet connection"];
          }];
}

- (void) errorShow: (NSString*)message {
    SCLAlertView* alert = [[SCLAlertView alloc] init];
    [alert showError:self.parentViewController title:@"Oups" subTitle:message closeButtonTitle:@"OK" duration:0.0f];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.facebookButton == nil) {
        UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                      20 + self.navigationController.navigationBar.frame.size.height,
                                                                      self.view.frame.size.width,
                                                                      40)];
        canvasView.backgroundColor = [UIColor whiteColor];
        canvasView.tag = 666;
        [self.navigationController.view addSubview:canvasView];
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                       canvasView.frame.size.height,
                                                                       canvasView.frame.size.width,
                                                                        1)];
        UISegmentedControl *searchSwitch = [[UISegmentedControl alloc] initWithItems:@[@"Users", @"Apps"]];
        [canvasView addSubview:searchSwitch];
        searchSwitch.tintColor = [UIColor chillMintColor];
        [searchSwitch setWidth:self.view.frame.size.width * 0.5 - 20 forSegmentAtIndex:0];
        [searchSwitch setWidth:self.view.frame.size.width * 0.5 - 20 forSegmentAtIndex:1];
        searchSwitch.center = CGPointMake(canvasView.frame.size.width * 0.5, canvasView.frame.size.height * 0.5 - 4);
        separatorView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [canvasView addSubview:separatorView];
        [searchSwitch addTarget:self action:@selector(switchSearch) forControlEvents:UIControlEventValueChanged];
        searchSwitch.selectedSegmentIndex = 0;
        self.searchSwitch = searchSwitch;
        self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top + 40,
                                                       self.tableView.contentInset.left,
                                                       self.tableView.contentInset.bottom,
                                                       self.tableView.contentInset.right);
        [self.tableView scrollRectToVisible:self.searchBar.frame animated:NO];
        
        UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        facebookButton.frame = CGRectMake(0, 0, 100, 20);
        [facebookButton setTitle:@"Facebook" forState:UIControlStateNormal];
        [facebookButton setTitleColor:[UIColor colorWithRed:0.18 green:0.27 blue:0.53 alpha:1.0] forState:UIControlStateNormal];
        facebookButton.center = CGPointMake(self.view.center.x, self.view.center.y - 100);
        [self.view addSubview:facebookButton];
        [self.view bringSubviewToFront:facebookButton];
        [facebookButton addTarget:self action:@selector(facebookButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        self.facebookButton = facebookButton;
        
        UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        twitterButton.frame = CGRectMake(0, 0, 100, 20);
        [twitterButton setTitle:@"Twitter" forState:UIControlStateNormal];
        [twitterButton setTitleColor:[UIColor colorWithRed:0.27 green:0.6 blue:0.91 alpha:1] forState:UIControlStateNormal];
        twitterButton.center = CGPointMake(self.view.center.x, self.view.center.y - 170);
        [self.view addSubview:twitterButton];
        [self.view bringSubviewToFront:twitterButton];
        [twitterButton addTarget:self action:@selector(twitterButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        self.twitterButton = twitterButton;
        
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shareButton.frame = CGRectMake(0, 0, 100, 20);
        [shareButton setTitle:@"Share" forState:UIControlStateNormal];
        [shareButton setTitleColor:[UIColor colorWithRed:0.9 green:0.65 blue:0.1 alpha:1] forState:UIControlStateNormal];
        shareButton.center = CGPointMake(self.view.center.x, self.view.center.y - 30);
        [self.view addSubview:shareButton];
        [self.view bringSubviewToFront:shareButton];
        [shareButton addTarget:self action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        self.shareButton = shareButton;
        
        [self searchSwitch];
    }
    [self.navigationController.view viewWithTag:666].hidden = NO;
}

- (void)shareButtonTapped
{
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    
    
    NSString *textToShare = [NSString stringWithFormat:@"Hey, add me on Chill! It's a fun way to communicate with no text or voice.\nGrab a promocode here: %@", [userCache valueForKey:@"promocode"]];
    NSURL *myWebsite = [NSURL URLWithString:[NSString stringWithFormat:@"http://iamchill.co/user/artstyle/promocode/%@", [userCache valueForKey:@"promocode"]]];
    
    NSArray *objectsToShare = @[textToShare, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludedActivities = @[
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo,
                                    UIActivityTypePostToTencentWeibo];
    activityVC.excludedActivityTypes = excludedActivities;
    
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)twitterButtonTapped
{
    [self.navigationController.view viewWithTag:666].hidden = YES;
    [self performSegueWithIdentifier:@"Twitter" sender:nil];
}

- (void)facebookButtonTapped
{
    [self.navigationController.view viewWithTag:666].hidden = YES;
    [self performSegueWithIdentifier:@"Facebook" sender:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Contact search screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)performSearchWithQuery:(NSString *)query
{
    NSString *fixedQuery = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    searchType = self.searchModeUsers ? 0 : 1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        _locations = [[[JSONLoader alloc] init] locationsFromJSONFile:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://api.iamchill.co/v3/search/index/id_user/%@/name/%@/type_search/%d", [userCache valueForKey:@"id_user"], fixedQuery, searchType]] typeJSON:@"Search"];
        NSLog(@"http://api.iamchill.co/v3/search/index/id_user/%@/name/%@", [userCache valueForKey:@"id_user"], query);
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    });
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self performSearchWithQuery:searchText];
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
        SCLAlertView* alert = [[SCLAlertView alloc] init];
        [alert showError:self.parentViewController title:@"Oups" subTitle:@"Please, check your internet connection" closeButtonTitle:@"OK" duration:0.0f];
    }
    else
    {
        [self performSearchWithQuery:searchBar.text];

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BOOL shouldHideButtons = _locations.count > 0;
    self.facebookButton.hidden = shouldHideButtons;
    self.twitterButton.hidden = shouldHideButtons;
    self.shareButton.hidden = shouldHideButtons;
    // Return the number of rows in the section.
    return _locations.count; //+ NUMBER_OF_STATIC_CELLS;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row < NUMBER_OF_STATIC_CELLS) {
//        return STATIC_CELL_HEIGHT;
//    }
//    return NORMAL_HEIGHT;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    SearchJSON *location = [_locations objectAtIndex:indexPath.row];
    location.who = (self.searchModeUsers) ? @0 : @1;

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    UILabel *nameLabel = (UILabel*) [cell viewWithTag:100];
    UILabel *twitterName = (UILabel*) [cell viewWithTag:1000];
    if ([location.who isEqualToNumber:@0]) // if it is a user
    {
      
        if (![location.login isKindOfClass:[NSNull class]])
        {
            nameLabel.text = location.login;
            if (![location.name isEqualToString:location.login] && ![location.name isEqualToString:@"(null)"])
            {
                twitterName.text =[NSString stringWithFormat:@"%@", location.name];
            }
            else
                twitterName.text = nil;
        }
            else nameLabel.text = location.login;
        }
    
    else // if it is an app
    {
        nameLabel.text = location.name;
        twitterName.text = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchModeUsers)
        [self addFriendFromIndex:indexPath.row];
    else {
        [self addAppFromIndex:indexPath.row];
        NSLog(@"try to add the app");
    }
}

- (void)addFriendFromIndex:(NSInteger)index {
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    
    NSMutableURLRequest *request =
    [[NSMutableURLRequest alloc] initWithURL:
     [NSURL URLWithString:@"http://api.iamchill.co/v2/contacts/index"]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    [request setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    
    SearchJSON *location = [_locations objectAtIndex:index];
    //location.who =
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


- (void)addAppFromIndex:(NSInteger)index {
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    
    NSMutableURLRequest *request =
    [[NSMutableURLRequest alloc] initWithURL:
     [NSURL URLWithString:@"http://api.iamchill.co/v3/contacts/index"]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    [request setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    
    SearchJSON *location = [_locations objectAtIndex:index];
    //location.who =
    friendUserId = [location.id_user integerValue];
    NSString *postString = [NSString stringWithFormat:@"id_user=%@&id_contact=%ld&type_contact=1",[userCache valueForKey:@"id_user"],(long)friendUserId];
    
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
//        NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
//        NSString *message = [NSString stringWithFormat:@"%@ wants to Chill with You!",[userCache valueForKey:@"name"]];
//        NSDictionary *data = @{
//                               @"alert": message,
//                               @"sound": @"default",
//                               @"badge" : @1,
//                               @"type": @"NewUser"
//                               };
//        PFPush *push = [[PFPush alloc] init];
//        [push setChannel:[NSString stringWithFormat:@"us%li",(long)friendUserId]]; //Set channel by user friend id
//        [push setData:data];
//        [push sendPushInBackground];
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
