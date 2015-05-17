//
//  CHLTableWatch.h
//  Chill
//
//  Created by Михаил Луцкий on 05.03.15.
//  Copyright (c) 2015 Victor Shamanov. All rights reserved.
//
#import <WatchKit/WatchKit.h>

#import <Foundation/Foundation.h>

@interface CHLTableWatch : NSObject
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lblTitle;
-(void) setTitle:(NSString *) title;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *share;
- (IBAction)shareclick;

@end
