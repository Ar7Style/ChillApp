//
//  CHLFriendCell.m
//  Chill
//
//  Created by Виктор Шаманов on 6/22/14.
//  Copyright (c) 2014 Victor Shamanov. All rights reserved.
//

#import "CHLFriendCell.h"

@implementation CHLFriendCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)prepareForReuse {
    [super prepareForReuse];
    self.type.image = nil;
    for (UIView *view in self.type.subviews) {
        [view removeFromSuperview];
        //чтобы наверняка
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
