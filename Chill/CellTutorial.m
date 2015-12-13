//
//  CellTutorial.m
//  Chill
//
//  Created by Михаил Луцкий on 11.12.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import "CellTutorial.h"

@implementation CellTutorial

- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)buttonAction:(id)sender {
    if (!tapped) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didGetMyNotification:)
                                                     name:@"Response"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ButtonSelected" object:buttonIDENT];

    }
    else {
        tapped = false;
        [_titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ButtonDeselected" object:buttonIDENT];

    }
}
- (void)didGetMyNotification:(NSNotification*)notification {
    if ([[notification object] isEqualToString:@"good"]) {
        [_titleButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        tapped = true;
    }
    else {
        [_titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)setID:(NSString *)buttonID {
    buttonIDENT = buttonID;
}
- (void)setTITLE:(NSString *)buttonNAME {
    buttonTITLE = buttonNAME;
}
@end
