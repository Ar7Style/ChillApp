//
//  CHLFavoriteViewController.m
//  Chill
//
//  Created by Tareyev Gregory on 04.12.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import "CHLFavoriteViewController.h"

@interface CHLFavoriteViewController ()

@end

@implementation CHLFavoriteViewController
- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
