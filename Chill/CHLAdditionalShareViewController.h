//
//  CHLAdditionalShareViewController.h
//  Chill
//
//  Created by Tareyev Gregory on 05.07.15.
//  Copyright (c) 2015 Victor Shamanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHLAdditionalShareViewController : UIViewController

@property (weak, nonatomic) UIImageView *cellStatusView;
@property (readwrite) NSInteger userIdTo;

@property(nonatomic, strong) NSMutableDictionary *progressViewsDictionary;

@end
