//
//  CHLLocationDisplayViewController.h
//  Chill
//
//  Created by Виктор Шаманов on 8/4/14.
//  Copyright (c) 2014 Victor Shamanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CHLLocationDisplayViewController : UIViewController

@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSString *locationTitle;
- (IBAction)close:(id)sender;

@end
