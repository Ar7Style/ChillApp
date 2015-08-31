//
//  CHLSearchViewController.h
//  Chill
//
//  Created by Михаил Луцкий on 13.12.14.
//  Copyright (c) 2015 Mikhail Loutskiy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHLSearchViewController : UITableViewController <UISearchBarDelegate>
- (IBAction)close:(id)sender;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
