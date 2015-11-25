//
//  ContactRow.h
//  Chill
//
//  Created by Михаил Луцкий on 22.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>
@interface ContactRow : NSObject
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *userName;
- (void) setName:(NSString*)title;
@end
