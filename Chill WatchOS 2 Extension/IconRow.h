//
//  IconRow.h
//  Chill
//
//  Created by Михаил Луцкий on 25.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>
#import "ButtonIconID.h"

@interface IconRow : NSObject
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *button1;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *button2;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *button3;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *titleName;
- (IBAction)b1;
- (IBAction)b2;
- (IBAction)b3;

@end
