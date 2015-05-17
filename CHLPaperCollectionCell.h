//
//  CHLPaperCollectionCell.h
//  Chill
//
//  Created by Ivan Grachev on 20/03/15.
//  Copyright (c) 2015 Victor Shamanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHLPaperCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *placeholderContentView;
@property (weak, nonatomic) IBOutlet UILabel *cellLabel;
@property (readwrite) NSInteger friendUserID;

@end
