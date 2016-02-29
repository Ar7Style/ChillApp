//
//  ContactsIC.h
//  Chill
//
//  Created by Михаил Луцкий on 22.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface ContactsIC : WKInterfaceController
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *table;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *statusLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *reloadButton;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceImage *statusIMG;
- (IBAction)reload;

@end
