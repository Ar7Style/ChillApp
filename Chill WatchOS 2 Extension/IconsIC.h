//
//  IconsIC.h
//  Chill
//
//  Created by Михаил Луцкий on 23.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface IconsIC : WKInterfaceController
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *iconButton;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *table;

@end
