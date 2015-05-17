//
//  LLACircularProgressView.m
//  LLACircularProgressView
//
//  Created by Lukas Lipka & Ivan Grachev on 26/10/13.
//  Copyright (c) 2013 Lukas Lipka. All rights reserved.
//

#import "LLACircularProgressView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ChillColors.h"

@interface LLACircularProgressView ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAShapeLayer *backgroundCircleLayer;
@property float radiusFactor;

@end

@implementation LLACircularProgressView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initProgressViewWithDummyProgress:(float)initialDummyProgress cellStatusView:(UIView *)cellStatusView {
    LLACircularProgressView *progressView = [[LLACircularProgressView alloc] initWithFrame:CGRectMake(0, 0, cellStatusView.frame.size.width, cellStatusView.frame.size.height)];
    progressView.tintColor =  [UIColor chillMintColor];
    [progressView setProgress:initialDummyProgress animated:YES];
    [cellStatusView.subviews.firstObject removeFromSuperview];
    [cellStatusView addSubview:progressView];
    
    if ([cellStatusView isKindOfClass:[UIImageView class]]) {
        [(UIImageView *)cellStatusView setImage:nil];
    }
    
    return progressView;
}

- (void)initialize {
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor clearColor];
    self.radiusFactor = 5;
    
    
    _progressLayer = [[CAShapeLayer alloc] init];
    _progressLayer.strokeColor = self.tintColor.CGColor;
    _progressLayer.strokeEnd = 0;
    _progressLayer.fillColor = nil;
    _progressLayer.lineWidth = 3;
    [self.layer addSublayer:_progressLayer];
    
    _backgroundCircleLayer = [[CAShapeLayer alloc] init];
    _backgroundCircleLayer.strokeColor = self.tintColor.CGColor;
    _backgroundCircleLayer.strokeEnd = 1;
    _backgroundCircleLayer.fillColor = nil;
    _backgroundCircleLayer.lineWidth = 1;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _backgroundCircleLayer.path = [UIBezierPath bezierPathWithArcCenter:center
                                                           radius:self.bounds.size.width / self.radiusFactor
                                                       startAngle:-M_PI_2
                                                         endAngle:-M_PI_2 + 2 * M_PI
                                                        clockwise:YES].CGPath;
    [self.layer addSublayer:_backgroundCircleLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.progressLayer.frame = self.bounds;

    [self updatePath];
    
    CABasicAnimation *infiniteRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [infiniteRotation setFromValue:@(0.0f)];
    [infiniteRotation setToValue:@((float)M_PI * 2.0f)];
    [infiniteRotation setDuration:1.5];
    [infiniteRotation setRepeatCount:INFINITY];
    [_progressLayer addAnimation:infiniteRotation forKey:@"rotationAnimation"];
}

#pragma mark - Accessors

- (void)setProgress:(float)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    if (progress > 0) {
        if (animated) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation.fromValue = self.progress == 0 ? @0 : nil;
            animation.toValue = [NSNumber numberWithFloat:progress];
            animation.duration = 1;
            animation.delegate = self;
            self.progressLayer.strokeEnd = progress;
            [self.progressLayer addAnimation:animation forKey:@"animation"];
        } else {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.progressLayer.strokeEnd = progress;
            [CATransaction commit];
        }
    } else {
        self.progressLayer.strokeEnd = 0.0f;
        [self.progressLayer removeAnimationForKey:@"animation"];
    }
    
    _progress = progress;
}

#pragma mark - Other

- (BOOL)currentlyContainsFilledProgressCircle {
    return [self.layer.sublayers containsObject:_progressLayer] && _progressLayer.strokeEnd == 1.0;
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
    if (finished) {
        [self showCheckMark];
    }
}

- (void)showCheckMark {
    [self.progressLayer removeFromSuperlayer];
    [self.backgroundCircleLayer removeFromSuperlayer];
    UIView *checkMarkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GreenCheckmark"]];
    checkMarkView.center = self.center;
    [self addSubview:checkMarkView];
    
    [UIView animateWithDuration:0.15
                          delay:1.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         checkMarkView.frame = CGRectMake(checkMarkView.frame.origin.x + self.bounds.size.width,
                                                          checkMarkView.frame.origin.y,
                                                          checkMarkView.frame.size.width,
                                                          checkMarkView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.progressLayer.strokeColor = self.tintColor.CGColor;
    self.backgroundCircleLayer.strokeColor = self.tintColor.CGColor;
    [self setNeedsDisplay];
}

#pragma mark - Private

- (void)updatePath {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.progressLayer.path = [UIBezierPath bezierPathWithArcCenter:center
                                                             radius:self.bounds.size.width / self.radiusFactor - 1
                                                         startAngle:-M_PI_2
                                                           endAngle:-M_PI_2 + 2 * M_PI
                                                          clockwise:YES].CGPath;
}

@end
