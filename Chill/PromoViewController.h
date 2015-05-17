//
//  PromoViewController.h
//  Chill
//
//  Created by Михаил Луцкий on 08.01.15.
//  Copyright (c) 2015 Victor Shamanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PromoViewController : UIViewController<UITextFieldDelegate> {
    bool isKeyboardShow;
}
@property (assign) UITapGestureRecognizer *tapRecognizer;
@property (weak, nonatomic) IBOutlet UITextField *promoField;
- (IBAction)go:(id)sender;
- (IBAction)goback:(id)sender;

@end
