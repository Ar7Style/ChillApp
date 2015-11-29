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
#import <CoreLocation/CoreLocation.h>

@interface ShareIC : WKInterfaceController <CLLocationManagerDelegate> {
    NSTimer *myTimer;
}
@property (nonatomic,retain) CLLocationManager *locationManager;

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *icon1;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *icon2;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *icon3;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *icon4;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *icon5;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *icon6;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfacePicker *countValue;
@property (strong, nonatomic) NSMutableArray <WKPickerItem *> *pickerItems;
@property (nonatomic, retain) NSTimer *myTimer;
- (IBAction)b1;
- (IBAction)b2;
- (IBAction)b3;
- (IBAction)b4;
- (IBAction)b5;
- (IBAction)b6;
- (IBAction)didChangeValue:(NSInteger)value;
- (IBAction)sendLocation;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *group1;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *group2;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *group3;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *statusText;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceImage *statusIMG;

@end
