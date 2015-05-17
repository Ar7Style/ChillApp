//
//  LLACircularProgressView.h
//  LLACircularProgressView
//
//  Created by Lukas Lipka & Ivan Grachev on 26/10/13.
//  Copyright (c) 2013 Lukas Lipka. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LLACircularProgressView : UIControl


@property (nonatomic) float progress;

- (instancetype)initProgressViewWithDummyProgress:(float)initialDummyProgress cellStatusView:(UIView *)cellStatusView;
- (void)setProgress:(float)progress animated:(BOOL)animated;
- (void)showCheckMark;
- (BOOL)currentlyContainsFilledProgressCircle;

@end
