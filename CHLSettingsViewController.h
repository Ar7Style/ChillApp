//
//  CHLSettingsViewController.h
//  Chill
//
//  Created by Tareyev Gregory on 04.02.15.
//  Copyright (c) 2015 Tareyev Gregory. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CHLSettingsViewController : UIViewController <UITextFieldDelegate>

{
    bool isKeyboardShow;
    
}

@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)actionTextChanged:(id)sender;

- (IBAction)Done:(id)sender;

@property (readwrite) NSString *email;
@property (readwrite) NSString *password;



@end
