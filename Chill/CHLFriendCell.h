//
//  CHLFriendCell.h
//  Chill
//
//  Created by Виктор Шаманов on 6/22/14.
//  Copyright (c) 2014 Victor Shamanov. All rights reserved.
//

#import "MCSwipeTableViewCell.h"

@interface CHLFriendCell : MCSwipeTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastChilTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *type;
@property (weak, nonatomic) IBOutlet UIView *shieldik;
@property (weak, nonatomic) IBOutlet UIView *shieldik2;

@end
