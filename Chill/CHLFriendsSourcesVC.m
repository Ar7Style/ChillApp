//
//  CHLFriendsSourcesVC.m
//  Chill
//
//  Created by Ivan Grachev on 7/17/15.
//  Copyright (c) 2015 Chill. All rights reserved.
//

#import "CHLFriendsSourcesVC.h"
#import "UIColor+ChillColors.h"
#import <AFNetworking/AFNetworking.h>



@interface CHLFriendsSourcesVC () {
    NSString* promocodeLink;
}

@property (weak, nonatomic) IBOutlet UITableViewCell *FromAddressBookButton;

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
    self.tableView.backgroundColor = [UIColor whiteColor];
    NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];
    [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    NSDictionary *parameters = @{@"id_user": [[NSUserDefaults standardUserDefaults] valueForKey:@"id_user"]};
    
    [manager POST:@"http://api.iamchill.co/v2/promocodes/index" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([[responseObject valueForKey:@"status"] isEqualToString:@"failed"]){
            [self errorShow:@"It seems that the entered email or password is incorrect"];
            NSLog(@"Fail promo");
        }
        else if ([[responseObject valueForKey:@"status"] isEqualToString:@"success"]) {
            [userCache setValue:[[responseObject valueForKey:@"response"] valueForKey:@"code"] forKey:@"promocode"];
            promocodeLink = [[responseObject valueForKey:@"response"] valueForKey:@"link"];
            [userCache synchronize];
            NSLog(@"Promo success: %@", [userCache valueForKey:@"promocode"]);
            
        }
    }
          failure:^(AFHTTPRequestOperation *operation2, NSError *error2) {
              [self errorShow:@"Please, check Your internet connection"];
          }];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView setBackgroundView:nil];
    [self addInvitationView];
}
- (void) errorShow: (NSString*)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {}];
    [alert addAction:okayAction];
    [self presentViewController:alert animated:YES completion:nil];
}
- (IBAction)shareButtonPressed:(id)sender {
    
    
    
        NSString *textToShare = [NSString stringWithFormat:@"Add me on contextual messenger I love using promocode: %@", promocodeLink];
        NSURL *myWebsite = [NSURL URLWithString:[NSString stringWithFormat:@"%@", promocodeLink]];
    
        NSArray *objectsToShare = @[textToShare, myWebsite];
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
        
    NSArray *excludedActivities = @[
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage,
                                    
                                    
                                    UIActivityTypeAssignToContact,
                                     UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    activityVC.excludedActivityTypes = excludedActivities;
    
    
        [self presentViewController:activityVC animated:YES completion:nil];
    
}


- (IBAction)fromAddressBookButtonPressed:(id)sender {
    
    
}

- (void)addInvitationView {
        self.invitationView = [[UIView alloc] initWithFrame:self.tableView.bounds];
        self.invitationView.userInteractionEnabled = NO;
        
        UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.55 * self.invitationView.frame.size.height, self.invitationView.frame.size.width, 70)];
        mainLabel.text = [NSString stringWithFormat:@"Search for friends"];
        mainLabel.textAlignment = NSTextAlignmentCenter;
        mainLabel.textColor = [UIColor chillMintColor];
        mainLabel.font = [UIFont boldSystemFontOfSize:26];
        
       // mainLabel.numberOfLines = 1;
        [self.invitationView addSubview:mainLabel];
        
        UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.55 * self.invitationView.frame.size.height + 50, self.invitationView.frame.size.width, 70)];
        subLabel.text = @"or invite from\nTwitter / Facebook";
        subLabel.textAlignment = NSTextAlignmentCenter;
        subLabel.textColor = [UIColor grayColor];
        subLabel.font = [UIFont systemFontOfSize:20];
        subLabel.numberOfLines = 2;
        [self.invitationView addSubview:subLabel];
        
        [self.tableView setBackgroundView:self.invitationView];
   
}


@end
