//
//  IconsIC.h
//  Chill
//
//  Created by Михаил Луцкий on 23.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface IconsIC : WKInterfaceController {
    NSTimer *myTimer;
}
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *iconButton;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *table;
@property (nonatomic, retain) NSTimer *myTimer;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *textMore;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceImage *statusIMG;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *statusText;

@end
