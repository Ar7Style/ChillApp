//
//  CHLTutorialViewController.m
//  Chill
//
//  Created by Ivan Grachev on 15/02/15.
//  Copyright (c) 2015 Chill. All rights reserved.
//

#import "CHLTutorialViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"
#import "CellTutorial.h"
#import "UserCache.h"
#import <AFNetworking/AFNetworking.h>
#define PAGE_AMOUNT 3

@interface CHLTutorialViewController () {
    NSMutableArray *selectedButtons;
    UITableView *tableView;
    NSArray *json;
}

@property (strong, nonatomic) UIPageViewController *pageViewController;

@end


@implementation CHLTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _table.delegate = self;
    _table.dataSource = self;
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPageViewController"];
    self.pageViewController.dataSource = self;
    
    CHLTutorialPageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//
    NSLog(@"2222");
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    selectedButtons = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGetMyNotification:)
                                                 name:@"ButtonSelected"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGetMyNotification1:)
                                                 name:@"ButtonDeselected"
                                               object:nil];

}
- (void)didGetMyNotification:(NSNotification*)notification {
    if (selectedButtons.count < 6) {
        [selectedButtons addObject:[notification object]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Response" object:@"good"];

    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Response" object:@"bad"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Limit" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    NSLog(@"%@", [notification object]);
}
- (void)didGetMyNotification1:(NSNotification*)notification {
    [selectedButtons removeObject:[notification object]];
    NSLog(@"%@", [notification object]);
}
- (void) close {
    NSString *str = @"";
    for (int i = 0; i < selectedButtons.count; i++) {
        str = [NSString stringWithFormat:@"%@%@-", str, selectedButtons[i]];
    }
    NSDictionary *parametr = @{@"id_user":[NSUserDefaults userID], @"id_icons_user":str};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
    [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    [manager POST:[NSString stringWithFormat:@"http://api.iamchill.co/v2/icons/index"] parameters:parametr success:^(NSURLSessionTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"]) {
                [self dismissViewControllerAnimated:YES completion:nil];
                [self.navigationController popViewControllerAnimated:YES];
        }
        NSLog(@"JSON123: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"FAILLLLL");
    }];
}
- (void) loadData {
//    NSDictionary *parametrs = @{@"id_user":[NSUserDefaults userID], @"id_contact":contactID, @"content":[buttonIDs objectForKey:[NSString stringWithFormat:@"%@",[notification object]]], @"type":@"icon"};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
    [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    [manager GET:[NSString stringWithFormat:@"http://api.iamchill.co/v2/icons/index/id_user/%@", [NSUserDefaults userID]] parameters:nil success:^(NSURLSessionTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"]) {
            json = [responseObject valueForKey:@"response"];
            [tableView reloadData];
        }
        NSLog(@"JSON123: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"FAILLLLL");
    }];

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Tutorial"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (UIView *)createContentViewForTutorialPage:(NSUInteger)index {
    //оставил здесь contentView, а не создал сразу ImageView, чтобы потом проще было менять/допиливать
    //👍
    UIView *contentView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    UIImageView *imageView;
    if (index == 0) {
        imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
        [contentView addSubview:imageView];
        imageView.image = [UIImage imageNamed:@"Portrait 1"];
    }
    if (index == 1) {
        imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
        [contentView addSubview:imageView];
        imageView.image = [UIImage imageNamed:@"Portrait 2"];
    }
    if (index == 2) {

        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-100) style:UITableViewStylePlain];
        UIButton *go = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-100, self.view.frame.size.width, 50)];
        [go setTitle:@"GO" forState:UIControlStateNormal];
        [go setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [go addTarget:self
                   action:@selector(close)
         forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:go];
        [self loadData];

        // must set delegate & dataSource, otherwise the the table will be empty and not responsive
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tableFooterView = [UIView new];

        tableView.backgroundColor = [UIColor whiteColor];
        
        
        // add to canvas
//        [self.view addSubview:tableView];
        [contentView addSubview:tableView];
//        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame];
//        [contentView addSubview:tableView];
//        tableView.delegate = self;
//        imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
//        [contentView addSubview:imageView];
//        imageView.image = [UIImage imageNamed:@"go_edu"];
    }
//    if (index == 3) {
//        imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
//        [contentView addSubview:imageView];
//        imageView.image = [UIImage imageNamed:@"Portrait 4"];
//    }
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return contentView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    
    // Similar to UITableViewCell, but
    CellTutorial *cell = [tableView1 dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [tableView1 registerNib:[UINib nibWithNibName:@"CellTutorial" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView1 dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    BOOL tapped = false;
    for (int i = 0; i < selectedButtons.count; i++) {
        if ([selectedButtons[i] isEqualToString:[NSString stringWithFormat:@"%li", (long)indexPath.row]]) {
            tapped = true;
        }
    }
    if (tapped) {
        [cell.titleButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        
    }
    else {
        [cell.titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        
    }


    [cell.titleButton setTitle:[json[indexPath.row] valueForKey:@"description"] forState:UIControlStateNormal];
    [cell setID:[NSString stringWithFormat:@"%li", (long)indexPath.row]];
    return cell;
}
#pragma mark - Page View Controller Data Source

- (CHLTutorialPageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if ((PAGE_AMOUNT == 0) || (index >= PAGE_AMOUNT)) {
        return nil;
    }
    
    CHLTutorialPageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPageContentViewController"];
    pageContentViewController.contentViewToPresent = [self createContentViewForTutorialPage: index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return PAGE_AMOUNT;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((CHLTutorialPageContentViewController *) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((CHLTutorialPageContentViewController *) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == PAGE_AMOUNT) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return json.count;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
