//
//  CHLPaperCollectionCell.h
//  Chill
//
//  Created by Ivan Grachev on 20/03/15.
//  Copyright (c) 2015 Chill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHLPaperCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *placeholderContentView;
@property (weak, nonatomic) IBOutlet UILabel *cellLabel;
@property (weak, nonatomic) IBOutlet UIImageView *timeLineImage;
@property (readwrite) NSInteger friendUserID;

@property (weak, nonatomic) IBOutlet UIButton *icon1;
@property (weak, nonatomic) IBOutlet UILabel *textLabel1;

@property (weak, nonatomic) IBOutlet UIButton *icon2;
@property (weak, nonatomic) IBOutlet UILabel *textLabel2;

@property (weak, nonatomic) IBOutlet UIButton *icon3;
@property (weak, nonatomic) IBOutlet UILabel *textLabel3;

@property (weak, nonatomic) IBOutlet UIButton *icon4;
@property (weak, nonatomic) IBOutlet UILabel *textLabel4;

@property (weak, nonatomic) IBOutlet UIButton *icon5;
@property (weak, nonatomic) IBOutlet UILabel *textLabel5;
- (IBAction)reply:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@end
