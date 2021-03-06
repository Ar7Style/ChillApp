//
//  CHLAddressBookViewController.h
//  Chill
//
//  Created by Виктор Шаманов on 7/10/14.
//  Copyright (c) 2014 Chill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHLAddressBookViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *contactsTableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property BOOL isFiltered;

@end
