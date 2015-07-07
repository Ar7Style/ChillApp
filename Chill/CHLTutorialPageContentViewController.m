//
//  CHLTutorialPageContentViewController.m
//  Chill
//
//  Created by Ivan Grachev on 15/02/15.
//  Copyright (c) 2015 Chill. All rights reserved.
//

#define PAGE_AMOUNT 4
//используется, чтобы решать, показывать кнопку GO или нет

#import "CHLTutorialPageContentViewController.h"
#import "UIColor+ChillColors.h"

@interface CHLTutorialPageContentViewController ()

@property (weak, nonatomic) IBOutlet UIButton *goButton;

@end

@implementation CHLTutorialPageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview: self.contentViewToPresent];
    [self.view sendSubviewToBack: self.contentViewToPresent];
    if (self.pageIndex == PAGE_AMOUNT - 1) {
        self.goButton.hidden = NO;
        [self.goButton setTitleColor:[UIColor chillMintColor] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)goButtonPressed:(UIButton *)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *friendListViewController = (UIViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"CHLFriendsListViewController"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController pushViewController:friendListViewController animated:YES];
    
//    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
