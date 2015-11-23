//
//  ShareICInterfaceController.h
//  Chill
//
//  Created by Михаил Луцкий on 22.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ShareIC : WKInterfaceController
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *icon1;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *icon2;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *icon3;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *icon4;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *icon5;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *icon6;

@end
