//
//  MessInterfaceController.h
//  Chill
//
//  Created by Михаил Луцкий on 01.04.15.
//  Copyright (c) 2015 Victor Shamanov. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface MessInterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;
- (IBAction)shareBut;
- (IBAction)geoBut;

@end
