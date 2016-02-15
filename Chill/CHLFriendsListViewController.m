#import "CHLFriendsListViewController.h"
#import "CHLShareViewController.h"
#import "CHLFriendCell.h"
#import "CHLFriendsListViewController.h"
#import "UIColor+ChillColors.h"
#import "SVPullToRefresh.h"
#import "MBProgressHUD.h"
#import <AFNetworking/AFNetworking.h>
#import "UIImageView+AFNetworking.h"
#import <Parse/Parse.h>
#import "APPROVEDViewController.h"
#import "AUTHViewController.h"
#import "HAPaperCollectionViewController.h"
#import "HACollectionViewLargeLayout.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"
#import "LLACircularProgressView.h"
#import "CHLSettingsViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import "UserCache.h"

#import "SCLAlertView.h"

#define UIColorFromRGBA(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]
#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]
@interface CHLFriendsListViewController () <MBProgressHUDDelegate, UIScrollViewDelegate, WCSessionDelegate> {
    MBProgressHUD *HUD;
    NSArray *json;
    long long expectedLength;
    long long currentLength;
    int numPost;
    NSTimer *timer;
}

@property(nonatomic, strong) NSMutableDictionary *progressViewsDictionary;

@end
NSMutableData *mutData;


@implementation CHLFriendsListViewController

#pragma mark - View controller lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([WCSession isSupported]) {
        WCSession* session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 81)];
    self.tableView.tableFooterView.backgroundColor = [UIColor whiteColor];
    UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    separatorLineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.tableView.tableFooterView addSubview:separatorLineView];
    [self logUser];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Friends list screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void) session:(nonnull WCSession *)session didReceiveApplicationContext:(nonnull NSDictionary<NSString *,id> *)applicationContext {
    if ([[applicationContext objectForKey:@"type"] isEqualToString:@"getAuth"]) {
        WCSession *session = [WCSession defaultSession];
        NSError *error;
        [session updateApplicationContext:@{@"userID": [NSUserDefaults userID], @"token":[NSUserDefaults userToken], @"isAuth":@"true", @"isApproved": @"true"} error:&error];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    self.navigationController.view.clipsToBounds=YES;
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    BOOL isAuthComplete = [userCache boolForKey:@"isAuth"];
    if (isAuthComplete){
        
        [self loadJSON];
        timer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                 target:self
                                               selector:@selector(targetMethod:)
                                               userInfo:nil
                                                repeats:YES];
        
    }
    else {
        AUTHViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Chill.AuthViewController"];
        [self presentViewController:vc animated:NO completion:nil];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    if( self.refreshControl.isRefreshing )
        [self refresh:self.refreshControl];
}
- (void)refresh:(id)sender {
    __weak UIRefreshControl *refreshControl = (UIRefreshControl *)sender;
    if(refreshControl.refreshing) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadJSON];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [refreshControl endRefreshing];
                [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            });
        });
    }
}
- (void) targetMethod: (id)sender {
    [self loadJSON];
}

- (void) errorShow: (NSString*)message {
    SCLAlertView* alert = [[SCLAlertView alloc] init];
    [alert showError:self.parentViewController title:@"Oups" subTitle:message closeButtonTitle:@"OK" duration:0.0f];
}

- (void) loadJSON {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
    [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    [manager GET:[NSString stringWithFormat:@"http://api.iamchill.co/v3/contacts/index/id_user/%@", [NSUserDefaults userID]] parameters:nil success:^(NSURLSessionTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"]) {
            if (![[responseObject objectForKey:@"response"] isEqualToArray:json]) {
                json = [responseObject objectForKey:@"response"];
                [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            }
        }
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [self errorShow:@"Please, check your internet connection"];
        NSLog(@"Error: %@", error);
    }];
}
#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor chillLightGrayColor];
        
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        label.text = @"New dialog";
        
        [view addSubview:label];
        
        view;
    });
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) return 0.0;
    return 0;
    
}

#pragma mark - Table view date source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return json.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHLFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSArray *jsonData = json[indexPath.row];
    
    UILabel* twitter_name = (UILabel*) [cell viewWithTag:10];
    if ( jsonData.count == 11) { // apps (without "login")
        cell.senderLabel.text = [jsonData valueForKey:@"name"];
        twitter_name.text = nil;
    }
    else { // users
        cell.senderLabel.text = [jsonData valueForKey:@"login"];
        if (![[jsonData valueForKey:@"name"] isEqualToString:[jsonData valueForKey:@"login"]] && ![[jsonData valueForKey:@"name"] isEqualToString:@"(null)"])
            twitter_name.text =[jsonData valueForKey:@"name"];
        else {
            twitter_name.text = nil;
            }
    }
    
    LLACircularProgressView *oldProgressView = (LLACircularProgressView *)[self.progressViewsDictionary objectForKey:[NSNumber numberWithInteger:[[jsonData valueForKey:@"id_contact"] integerValue]]];
    if (cell.type.subviews.firstObject && oldProgressView && cell.type.subviews.firstObject != oldProgressView) {
        [cell.type.subviews.firstObject removeFromSuperview];
    }
    else if (oldProgressView) {
        if (!cell.type.subviews.firstObject || [(LLACircularProgressView *)cell.type.subviews.firstObject currentlyContainsFilledProgressCircle]) {
            if (oldProgressView.progress == 1.0) {
                [self.progressViewsDictionary removeObjectForKey:[NSNumber numberWithInteger:[[jsonData valueForKey:@"id_contact"] integerValue]]];
                [oldProgressView showCheckMark];
                [cell.type addSubview:oldProgressView];
            }
            else if (oldProgressView.progress != 1.0) {
                LLACircularProgressView *newProgressView = [[LLACircularProgressView alloc] initProgressViewWithDummyProgress:0.0 cellStatusView:cell.type];
                [newProgressView setProgress:oldProgressView.progress];
                [self.progressViewsDictionary setObject:newProgressView forKey:[NSNumber numberWithInteger:[[jsonData valueForKey:@"id_contact"] integerValue]]];
            }
        }
    }
    
    
    if (![[jsonData valueForKey:@"email"] isEqualToString:@"chillteam@iamchill.co"]){
        cell.shieldik.hidden  = NO;
        cell.shieldik2.hidden = NO;
        if (![[jsonData valueForKey:@"read"] isKindOfClass:[NSNull class]]) {
            if ([[jsonData valueForKey:@"read"] isEqualToString:@"0"] && !cell.type.subviews.firstObject) {
                
                [cell.type setImageWithURL:[NSURL URLWithString:[json[indexPath.row] valueForKey:@"size42"]]]; 

            }
            
            else {
                UIImage *image = [UIImage imageNamed: @""];
                [cell.type setImage:image];
            }
        }
        UIView *swipeView = [[UIView alloc] initWithFrame:cell.bounds];
        swipeView.backgroundColor = [UIColor chillMintColor];
        
        [cell setSwipeGestureWithView:swipeView
                                color:swipeView.backgroundColor
                                 mode:MCSwipeTableViewCellModeExit
                                state:MCSwipeTableViewCellState1
                      completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                          
                          [self performSegueWithIdentifier:NSStringFromClass([CHLShareViewController class]) sender:cell];
                          [cell swipeToOriginWithCompletion:nil];
                          
                      }];
    }
    else{
        cell.shieldik.hidden = YES;
        cell.shieldik2.hidden = YES;
    }
    /*
     NSURL *avatarURL = [NSURL URLWithString:user.thumbImageURL];
     
     [cell.avatarImageView setImageWithURL:avatarURL];
     
     cell.avatarImageView.layer.cornerRadius = 18.0;
     cell.avatarImageView.layer.masksToBounds = YES;
     */
    
    
    
    return cell;
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *jsonData = json[indexPath.row];
    
    if ([[jsonData valueForKey:@"email"] isEqualToString:@"chillteam@iamchill.co"]) {
        return NO;
    }
    else {
        // Return NO if you do not want the specified item to be editable.
        return YES;
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete object from database
        NSArray *jsonData = json[indexPath.row];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"]; //@"group.Chill"
        
        //        NSError *error = nil;
        
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.iamchill.co/v2/contacts/delete/"]]];
        [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"]; [request setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
        
        
        //NSString *postString = [NSString stringWithFormat:@"id_user/%@", [userCache valueForKey:@"id_user"]];
        
        
        
        NSString *postString = [NSString stringWithFormat:@"id_user=%@&id_contact=%@", [userCache valueForKey:@"id_user"], [jsonData valueForKey:@"id_contact"]];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[postString
                              dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        if (connection) {
            mutData = [NSMutableData data];
        }
        
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        
    }
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [HUD hide:YES];
    [self loadJSON];
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

-(void)shakeAnimation:(UITableViewCell*) cell
{
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
    [shake setDuration:0.1];
    //[shake setRepeatCount:2];
    [shake setAutoreverses:YES];
    [shake setFromValue:[NSValue valueWithCGPoint:
                         CGPointMake(cell.center.x ,cell.center.y)]];
    [shake setToValue:[NSValue valueWithCGPoint:
                       CGPointMake(cell.center.x + 25, cell.center.y)]];
    [cell.layer addAnimation:shake forKey:@"position"];
}


#pragma mark - Private methods

- (NSMutableDictionary *) progressViewsDictionary {
    if (!_progressViewsDictionary) {
        _progressViewsDictionary = [[NSMutableDictionary alloc] init];
    }
    return _progressViewsDictionary;
}

- (UIImage *) changeColorForImage:(UIImage *)image toColor:(UIColor*)color {
    UIGraphicsBeginImageContext(image.size);
    
    CGRect contextRect;
    contextRect.origin.x = 0.0f;
    contextRect.origin.y = 0.0f;
    contextRect.size = [image size];
    // Retrieve source image and begin image context
    CGSize itemImageSize = [image size];
    CGPoint itemImagePosition;
    itemImagePosition.x = ceilf((contextRect.size.width - itemImageSize.width) / 2);
    itemImagePosition.y = ceilf((contextRect.size.height - itemImageSize.height) );
    
    UIGraphicsBeginImageContext(contextRect.size);
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    // Setup shadow
    // Setup transparency layer and clip to mask
    CGContextBeginTransparencyLayer(c, NULL);
    CGContextScaleCTM(c, 1.0, -1.0);
    CGContextClipToMask(c, CGRectMake(itemImagePosition.x, -itemImagePosition.y, itemImageSize.width, -itemImageSize.height), [image CGImage]);
    // Fill and end the transparency layer
    
    
    //const float* colors = CGColorGetComponents( color.CGColor );
    //CGContextSetRGBFillColor(c, colors[0], colors[1], colors[2], .75);
    
    contextRect.size.height = -contextRect.size.height;
    contextRect.size.height -= 15;
    CGContextFillRect(c, contextRect);
    CGContextEndTransparencyLayer(c);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


- (void)showError:(NSError *)error {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:error.localizedFailureReason
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {}];
    [alert addAction:okayAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NSStringFromClass([CHLShareViewController class])]) {
        [timer invalidate];
        timer = nil;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSArray *jsonData = json[indexPath.row];
        
        CHLShareViewController *shareViewController = segue.destinationViewController;
        HAPaperCollectionViewController* hapcvc = [[HAPaperCollectionViewController alloc] init];
        hapcvc.nickName = [jsonData valueForKey:@"login"];
        
        shareViewController.userIdTo = [[jsonData valueForKey:@"id_contact"] integerValue];
        shareViewController.nameUser = [jsonData valueForKey:@"login"];
        shareViewController.cellStatusView = [(CHLFriendCell *)sender type];
        shareViewController.progressViewsDictionary = self.progressViewsDictionary;
    }
    
    else if ([segue.identifier isEqualToString:@"toTheSettings"]) {
        [timer invalidate];
        timer = nil;
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [timer invalidate];
    timer = nil;
    HAPaperCollectionViewController *myNewVC = [[HAPaperCollectionViewController alloc] init];
    HACollectionViewLargeLayout *aFlowLayout = [[HACollectionViewLargeLayout alloc] init];
    NSArray *jsonData = json[indexPath.row];
    myNewVC = [[HAPaperCollectionViewController alloc]initWithCollectionViewLayout:aFlowLayout];
    myNewVC.friendUserID = [[jsonData valueForKey:@"id_contact"] integerValue];
    myNewVC.cellStatusView = [(CHLFriendCell *)[tableView cellForRowAtIndexPath:indexPath] type];
    myNewVC.progressViewsDictionary = self.progressViewsDictionary;
    if (![[jsonData valueForKey:@"name"] isKindOfClass:[NSNull class]]){
        myNewVC.nickName = [jsonData valueForKey:@"name"];
    }
    else     myNewVC.nickName = [jsonData valueForKey:@"login"];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Friends list screen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"Contact from friends list tapped"
                                                           label:nil
                                                           value:nil] build]];
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    //if (![location.email isEqualToString:@"chillteam@iamchill.co"] )
    //  [self shakeAnimation:cell];
    if ([jsonData valueForKey:@"content"] == (id)[NSNull null] && ![[jsonData valueForKey:@"email"] isEqualToString:@"chillteam@iamchill.co"])
        [self shakeAnimation:cell];
    else {
        [self presentViewController:myNewVC animated:NO completion:nil];
    }
    
}
- (void) logUser {
    
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    
    [CrashlyticsKit setUserIdentifier:[userCache valueForKey:@"id_user"]];
    [CrashlyticsKit setUserEmail:[userCache valueForKey:@"email"]];
    [CrashlyticsKit setUserName:[userCache valueForKey:@"login_user"]];
}


@end