//
//  CHLShareViewController.h
//  Chill
//
//  Created by Виктор Шаманов on 6/1/14.
//  Copyright (c) 2014 Victor Shamanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class CHLShareViewController;


@protocol CHLShareViewControllerDelegate <NSObject>

- (void)shareViewController:(CHLShareViewController *)shareViewController didSelectImage:(UIImage *)image;
- (void)shareIconOfType:(NSString *)iconType;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;

@end

@interface CHLShareViewController : UIViewController 

@property (assign, nonatomic) BOOL isNonChillUser;
@property (readwrite) NSInteger userIdTo;
@property (readwrite) NSString *nameUser;
@property (weak, nonatomic) UIImageView *cellStatusView;
@property(nonatomic, strong) NSMutableDictionary *progressViewsDictionary;
//@property (readwrite) NSInteger friendUserID;


@property (weak, nonatomic) id <CHLShareViewControllerDelegate> delegate;

@end
