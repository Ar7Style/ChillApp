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

#import "UIViewController+KeyboardAnimation.h"

#import "UserCache.h"

@interface CHLPromoViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrBottom;

@end

@implementation CHLPromoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    [_promocodeTextField resignFirstResponder];
}


-(void)viewWillAppear:(BOOL)animated {
    __weak __typeof(self) weakSelf = self;
        [self an_subscribeKeyboardWithAnimations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {
        __typeof__(self) strongSelf = weakSelf;
        self.constrBottom.constant = isShowing ?  CGRectGetHeight(keyboardRect) : 170;
        [self.view layoutIfNeeded];
    } completion:nil];
    //[self.view layoutIfNeeded];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self an_unsubscribeKeyboard];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goButtonPressed:(id)sender {
    _goButton.userInteractionEnabled = NO;
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
            [alert showError:self.parentViewController title:@"Oups" subTitle:@"Sorry, promocode is incorrect" closeButtonTitle:@"OK" duration:0.0f];
            _goButton.userInteractionEnabled = YES;
        }
    }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            SCLAlertView* alert = [[SCLAlertView alloc] init];
            [alert showError:self.parentViewController title:@"Oups" subTitle:@"Please, check Your internet connection" closeButtonTitle:@"OK" duration:0.0f];
            _goButton.userInteractionEnabled = YES;
        
    }];
    
}
- (IBAction)skipButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"toTutorialFromPromoVC" sender:self];
}
     
- (void) errorShow: (NSString*)message {
    SCLAlertView* alert = [[SCLAlertView alloc] init];
    [alert showError:self.parentViewController title:@"Oups" subTitle:message closeButtonTitle:@"OK" duration:0.0f];
}

@end
