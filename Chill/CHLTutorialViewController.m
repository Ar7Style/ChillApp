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

#define PAGE_AMOUNT 3

@interface CHLTutorialViewController ()

@property (strong, nonatomic) UIPageViewController *pageViewController;

@end


@implementation CHLTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPageViewController"];
    self.pageViewController.dataSource = self;
    
    CHLTutorialPageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
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
        imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
        [contentView addSubview:imageView];
        imageView.image = [UIImage imageNamed:@"go_edu"];
    }
//    if (index == 3) {
//        imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
//        [contentView addSubview:imageView];
//        imageView.image = [UIImage imageNamed:@"Portrait 4"];
//    }
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return contentView;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
