//
//  CHLFriendsSourcesVC.m
//  Chill
//
//  Created by Ivan Grachev on 7/17/15.
//  Copyright (c) 2015 Victor Shamanov. All rights reserved.
//

#import "CHLFriendsSourcesVC.h"
#import "UIColor+ChillColors.h"

@interface CHLFriendsSourcesVC ()

@property(nonatomic, strong) UIView *invitationView;

@end

@implementation CHLFriendsSourcesVC

- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor chillMintColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView setBackgroundView:nil];
    [self addInvitationView];
}

- (void)addInvitationView {
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    if ([userCache integerForKey:@"Available invites number"] != 0) {
        self.invitationView = [[UIView alloc] initWithFrame:self.tableView.bounds];
        self.invitationView.userInteractionEnabled = NO;
        
        NSArray *friendsAmountStrings = @[@"1 more friend", @"2 more friends", @"3 friends"];
        NSString *chosenFriendsAmountString = friendsAmountStrings[[userCache integerForKey:@"Available invites number"] - 1];
        UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.55 * self.invitationView.frame.size.height, self.invitationView.frame.size.width, 70)];
        mainLabel.text = [NSString stringWithFormat:@"Help %@\nto get Chill", chosenFriendsAmountString];
        mainLabel.textAlignment = NSTextAlignmentCenter;
        mainLabel.textColor = [UIColor grayColor];
        mainLabel.font = [UIFont boldSystemFontOfSize:26];
        mainLabel.numberOfLines = 2;
        [self.invitationView addSubview:mainLabel];
        
        UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.55 * self.invitationView.frame.size.height + 70, self.invitationView.frame.size.width, 70)];
        subLabel.text = @"or add the ones\nalready Chilling";
        subLabel.textAlignment = NSTextAlignmentCenter;
        subLabel.textColor = [UIColor grayColor];
        subLabel.font = [UIFont systemFontOfSize:20];
        subLabel.numberOfLines = 2;
        [self.invitationView addSubview:subLabel];
        
        [self.tableView setBackgroundView:self.invitationView];
    }
}


@end
