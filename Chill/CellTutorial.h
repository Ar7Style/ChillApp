//
//  CellTutorial.h
//  Chill
//
//  Created by Михаил Луцкий on 11.12.15.
//  Copyright © 2015 Chlil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellTutorial : UITableViewCell {
    NSString* buttonIDENT;
    NSString* buttonTITLE;
    BOOL tapped;
    NSMutableDictionary *tappedButtons;
}
@property (weak, nonatomic) IBOutlet UIButton *titleButton;
- (IBAction)buttonAction:(id)sender;
- (void) setID:(NSString*)buttonID;
- (void) setTITLE:(NSString*)buttonNAME;
@end
