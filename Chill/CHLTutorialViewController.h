//
//  CHLTutorialViewController.h
//  Chill
//
//  Created by Ivan Grachev on 15/02/15.
//  Copyright (c) 2015 Chill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHLTutorialPageContentViewController.h"

@interface CHLTutorialViewController : UIViewController <UIPageViewControllerDataSource, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *table;

@end
