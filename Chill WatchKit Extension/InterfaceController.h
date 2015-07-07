//
//  InterfaceController.h
//  Chill WatchKit Extension
//
//  Created by Михаил Луцкий on 04.03.15.
//  Copyright (c) 2015 Chill. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController 
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;

@end
