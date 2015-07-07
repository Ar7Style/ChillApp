//
//  CHLAdditionalShareViewController.h
//  Chill
//
//  Created by Tareyev Gregory on 05.07.15.
//  Copyright (c) 2015 Chill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "LLACircularProgressView.h"

@interface CHLAdditionalShareViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) UIImageView *cellStatusView;
@property (readwrite) NSInteger userIdTo;
@property (readwrite) LLACircularProgressView* progressView;

@property(nonatomic, strong) NSMutableDictionary *progressViewsDictionary;
- (IBAction)showEmail:(id)sender;

@end
