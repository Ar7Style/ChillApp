//
//  CHLTableMessWK.h
//  Chill
//
//  Created by Михаил Луцкий on 01.04.15.
//  Copyright (c) 2015 Victor Shamanov. All rights reserved.
//
#import <WatchKit/WatchKit.h>

#import <Foundation/Foundation.h>

@interface CHLTableMessWK : NSObject
-(void) setImage:(UIImage *) image;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *butimg;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *image3;

@end
