//
//  IconRow.m
//  Chill
//
//  Created by Михаил Луцкий on 25.11.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import "IconRow.h"

@implementation IconRow

- (IBAction)b1 {
//    NSLog(@"button %@", _button1);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"buttonPressed" object:_button1];

}

- (IBAction)b2 {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"buttonPressed" object:_button2];

}

- (IBAction)b3 {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"buttonPressed" object:_button3];

}
@end
