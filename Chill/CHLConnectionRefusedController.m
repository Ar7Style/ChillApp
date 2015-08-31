//
//  CHLConnectionRefusedController.m
//  Chill
//
//  Created by Tareyev Gregory on 09.03.15.
//  Copyright (c) 2015 Chill. All rights reserved.
//

#import "CHLConnectionRefusedController.h"
#import "UIColor+ChillColors.h"

@interface CHLConnectionRefusedController ()

@end



@implementation CHLConnectionRefusedController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _messageView.image = [UIImage imageNamed:@"No_internet"];
    _messageView.contentMode = UIViewContentModeScaleAspectFit;

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
