//
//  AUTHViewController.h
//  Chill
//
//  Created by Михаил Луцкий on 16.11.14.
//  Copyright (c) 2014 Victor Shamanov. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AUTHViewController : UIViewController<UITextFieldDelegate> {
    bool isKeyboardShow;
}
@property (weak, nonatomic) IBOutlet UIButton *authButton1;
@property (weak, nonatomic) IBOutlet UITextField *loginField1;
@property (weak, nonatomic) IBOutlet UITextField *passwordField1;
@property (assign) UITapGestureRecognizer *tapRecognizer;
- (IBAction)nextBut:(id)sender;

@end
