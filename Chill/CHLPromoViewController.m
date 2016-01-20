//
//  CHLPromoViewController.m
//  Chill
//
//  Created by Tareyev Gregory on 20.01.16.
//  Copyright © 2016 Chlil. All rights reserved.
//

#import "CHLPromoViewController.h"

#import <AFNetworking/AFNetworking.h>
#import "SCLAlertView.h"

#import "UserCache.h"

@interface CHLPromoViewController ()

@end

@implementation CHLPromoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goButtonPressed:(id)sender {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSUserDefaults userToken] forHTTPHeaderField:@"X-API-TOKEN"];
    [manager.requestSerializer setValue:@"76eb29d3ca26fe805545812850e6d75af933214a" forHTTPHeaderField:@"X-API-KEY"];
    [manager GET:[NSString stringWithFormat:@"http://api.iamchill.co/v2/promocodes/index/id_user/%@/promocode/%@",[NSUserDefaults userID], _promocodeTextField.text] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject valueForKey:@"status"] isEqualToString:@"success"])
        {
            [self performSegueWithIdentifier:@"toTutorialFromPromoVC" sender:self];
        }
        else if ([[responseObject valueForKey:@"status"] isEqualToString:@"failed"]) {
            SCLAlertView* alert = [[SCLAlertView alloc] init];
            [alert showError:self.parentViewController title:@"Failed" subTitle:@"Sorry, promocode is incorrect" closeButtonTitle:@"OK" duration:0.0f];
        }
    }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self errorShow:@"Please, check Your internet connection"];
    }];
    
}
- (IBAction)skipButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"toTutorialFromPromoVC" sender:self];
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

@end
