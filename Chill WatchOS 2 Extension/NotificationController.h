//
//  NotificationController.h
//  Chill WatchOS 2 Extension
//
//  Created by Михаил Луцкий on 22.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface NotificationController : WKUserNotificationInterfaceController
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceImage *image;

@end
