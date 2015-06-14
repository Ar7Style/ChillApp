//
//  CHLAdditionalShareViewController.m
//  Chill
//
//  Created by Tareyev Gregory on 14.06.15.
//  Copyright (c) 2015 Victor Shamanov. All rights reserved.
//

#import "CHLAdditionalShareViewController.h"

@interface CHLAdditionalShareViewController ()

@end

@implementation CHLAdditionalShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *CHLFriendsListViewController = (UIViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"CHLFriendsListViewController"];
    
    [self.navigationController pushViewController:CHLFriendsListViewController animated:YES];
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
