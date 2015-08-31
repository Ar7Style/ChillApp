//
//  CHLInviteFromAddressBookViewController.m
//  Chill
//
//  Created by Tareyev Gregory on 05.08.15.
//  Copyright (c) 2015 Chlil. All rights reserved.
//

#import "CHLInviteFromAddressBookViewController.h"
#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>
#import "CHLAddressBookViewController.h"
#import "CHLFriendsSourcesVC.h"

@interface CHLInviteFromAddressBookViewController () <MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>

@end

@implementation CHLInviteFromAddressBookViewController

- (void)viewDidLoad {
   // [super viewDidLoad];
    
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
        messageViewController.messageComposeDelegate = self;
        messageViewController.body = @"✌️ 😉 😆 👇\n Check out Chill - a textless/voiceless commutication app I love!\n http://iamchill.co";
        [self presentViewController:messageViewController animated:YES completion:nil];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                       message:@"Sorry, messages are not available on your device"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {}];
        [alert addAction:okayAction];
        [self presentViewController:alert animated:YES completion:nil];
    }

    // Do any additional setup after loading the view.
}


-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {

    [controller dismissViewControllerAnimated:YES completion:nil];
  }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
