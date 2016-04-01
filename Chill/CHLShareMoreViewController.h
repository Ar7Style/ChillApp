//
//  CHLShareMoreViewController.h
//  Chill
//
//  Created by Ivan Grachev on 2/19/16.
//  Copyright © 2016 Chlil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHLShareMoreViewController : UIViewController

@property (weak, nonatomic) UIImageView *cellStatusView;
@property (readwrite) NSInteger userIdTo;
@property(nonatomic, strong) NSMutableDictionary *progressViewsDictionary;
@property(nonatomic, strong) NSString *tempText;
@property (weak, nonatomic) IBOutlet UITextField *hashtagTextField;



@end
