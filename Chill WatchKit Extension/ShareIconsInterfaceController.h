//
//  ShareIconsInterfaceController.h
//  Chill
//
//  Created by Михаил Луцкий on 25.04.15.
//  Copyright (c) 2015 Chill. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface ShareIconsInterfaceController : WKInterfaceController
- (IBAction)clock;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *beer;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *coffee;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *stamp;
- (IBAction)beerbut;
- (IBAction)coffeebut;
- (IBAction)stampbut;
- (IBAction)chillbut;
- (IBAction)rocketbut;

@end
