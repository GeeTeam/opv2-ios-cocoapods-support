//
//  GOPIndicatorView.m
//  OnePassLoading
//
//  Created by NikoXu on 09/11/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import "GOPIndicatorView.h"

#import "CABasicAnimation+GOP.h"
#import "UIView+GOP.h"

CGFloat const GOPInnerFactor = 10.f/16;
CGFloat const GOPBorderFactor = 2.f/16;
//CGFloat const GOP

@interface GOPIndicatorView ()

@property (nonatomic, strong) UIColor *mainColor;

@property (nonatomic, strong) CAShapeLayer *checker;
@property (nonatomic, strong) CAShapeLayer *stopLine;
@property (nonatomic, strong) CAShapeLayer *outerRound;
@property (nonatomic, strong) CAShapeLayer *innerRound;

@end

@implementation GOPIndicatorView

- (instancetype)initWithFrame:(CGRect)frame mainColor:(UIColor *)color {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.mainColor = color;
        
        self.checker = [[CAShapeLayer alloc] init];
        self.stopLine = [[CAShapeLayer alloc] init];
        self.outerRound = [[CAShapeLayer alloc] init];
        self.innerRound = [[CAShapeLayer alloc] init];
        
        [self setupChecker];
        [self setupStopLine];
        [self setupInnerRound];
        [self setupOuterRound];
    }
    
    return self;
}

- (void)load:(void (^)(void))completion {
    if (self.state > GOPIndicatorStateLoading) return;
    self.state = GOPIndicatorStateLoading;
    
    self.checker.opacity = 0.f;
    self.stopLine.opacity = 0.f;
    self.outerRound.opacity = 1.f;
    self.innerRound.opacity = 1.f;
    
    CGFloat width = .0f;
    CGRect rect = CGRectMake((self.gop_width-width)/2, (self.gop_width-width)/2, width, width);
    
    UIBezierPath *outerPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:width/2];
    
//    CABasicAnimation *scale = [CABasicAnimation gop_animationWithDuration:1.2 delay:0 fromValue:@(1.0f) toValue:@(0.f) autoreversed:NO keyPath:@"transform.scale"];
    CABasicAnimation *opacity = [CABasicAnimation gop_animationWithBeginTime:CACurrentMediaTime() duration:0.3 fromValue:@(1.0) toValue:@(0.0f) autoreversed:NO keyPath:@"opacity"];
    CABasicAnimation *scale = [CABasicAnimation gop_animationWithBeginTime:CACurrentMediaTime() duration:0.3 fromValue:nil toValue:(id)outerPath.CGPath autoreversed:NO keyPath:@"path"];
    
    [self.innerRound addAnimation:scale forKey:@"scale"];
    [self.innerRound addAnimation:opacity forKey:@"opacity"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) completion();
    });
}

- (void)loop {
    if (self.state > GOPIndicatorStateLooping) return;
    self.state = GOPIndicatorStateLooping;
    
    self.checker.opacity = 0.f;
    self.stopLine.opacity = 0.f;
    self.outerRound.opacity = 1.f;
    self.innerRound.opacity = 0.f;
    
    CABasicAnimation *endPath = [CABasicAnimation gop_animationWithBeginTime:0.0 duration:0.6 fromValue:@(0.f) toValue:@(1.f) autoreversed:NO keyPath:@"strokeEnd"];
    CABasicAnimation *startPath = [CABasicAnimation gop_animationWithBeginTime:0.6 duration:0.6 fromValue:@(0.f) toValue:@(1.f) autoreversed:NO keyPath:@"strokeStart"];
    
    CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
    [group setAnimations:@[endPath, startPath]];
    [group setBeginTime:CACurrentMediaTime()];
    [group setDuration:1.2f];
    [group setRepeatCount:HUGE_VALF];
    group.removedOnCompletion = NO;
    
    [self.outerRound removeAllAnimations];
    [self.outerRound addAnimation:group forKey:@"group"];
}

- (void)finish:(void (^)(void))completion {
    if (self.state > GOPIndicatorStateFinish) return;
    self.state = GOPIndicatorStateFinish;
    
    self.checker.opacity = 1.f;
    self.stopLine.opacity = 0.f;
    self.outerRound.opacity = 1.f;
    self.innerRound.opacity = 0.f;
    
    
    CABasicAnimation *endPath = [CABasicAnimation gop_animationWithBeginTime:CACurrentMediaTime() duration:0.3 fromValue:nil toValue:@(1.f) autoreversed:NO keyPath:@"strokeEnd"];
    CABasicAnimation *startPath = [CABasicAnimation gop_animationWithBeginTime:CACurrentMediaTime() duration:0.3 fromValue:nil toValue:@(0.f) autoreversed:NO keyPath:@"strokeStart"];
    CABasicAnimation *opacity = [CABasicAnimation gop_animationWithBeginTime:CACurrentMediaTime() duration:0.3 fromValue:@(0.3f) toValue:@(1.f) autoreversed:NO keyPath:@"opacity"];
    
    [self.outerRound removeAllAnimations];
    [self.outerRound addAnimation:endPath forKey:@"strokeEnd"];
    [self.outerRound addAnimation:startPath forKey:@"strokeStart"];
    [self.checker addAnimation:opacity forKey:@"opacity"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) completion();
    });
}

- (void)stop:(void (^)(void))completion {
    if (self.state > GOPIndicatorStateStop) return;
    self.state = GOPIndicatorStateStop;
    
    self.checker.opacity = 0.f;
    self.stopLine.opacity = 1.f;
    self.outerRound.opacity = 1.f;
    self.innerRound.opacity = 0.f;
    
    [self.outerRound removeAllAnimations];
    
    CABasicAnimation *stroke = [CABasicAnimation gop_animationWithBeginTime:CACurrentMediaTime() duration:0.3 fromValue:@(0.f) toValue:@(1.f) autoreversed:NO keyPath:@"strokeEnd"];
    CABasicAnimation *opacity = [CABasicAnimation gop_animationWithBeginTime:CACurrentMediaTime() duration:0.3 fromValue:@(0.6f) toValue:@(1.f) autoreversed:NO keyPath:@"opacity"];
    
    [self.stopLine addAnimation:stroke forKey:@"strokeStart"];
    [self.stopLine addAnimation:opacity forKey:@"opacity"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) completion();
    });
}

- (void)setupChecker {
    CGFloat width = self.gop_width;
    
    UIBezierPath *checkPath = [UIBezierPath bezierPath];
    [checkPath moveToPoint:CGPointMake(width*13/44, width*21/44)];
    [checkPath addLineToPoint:CGPointMake(width*19/44, width*29/44)];
    [checkPath addLineToPoint:CGPointMake(width*32/44, width*16/44)];
    self.checker.frame = CGRectMake(0, 0, width, width);
    self.checker.anchorPoint = CGPointMake(0.5, 0.5);
    self.checker.path = checkPath.CGPath;
    self.checker.strokeColor = self.mainColor.CGColor;
    self.checker.fillColor = [UIColor clearColor].CGColor;
    self.checker.lineWidth = self.lineWidth ? self.lineWidth : 2.f;
    self.checker.lineCap = kCALineCapRound;
    self.checker.lineJoin = kCALineJoinMiter;
    self.checker.strokeStart = 0.f;
    self.checker.strokeEnd = 1.f;
    self.checker.opacity = 0.f;
    [self.layer addSublayer:self.checker];
}

- (void)setupStopLine {
    CGFloat width = self.gop_width;
    
    UIBezierPath *stopPath = [UIBezierPath bezierPath];
    [stopPath moveToPoint:CGPointMake(width*15/44, width*22/44)];
    [stopPath addLineToPoint:CGPointMake(width*29/44, width*22/44)];
    self.stopLine.frame = CGRectMake(0, 0, width, width);
    self.stopLine.anchorPoint = CGPointMake(0.5, 0.5);
    self.stopLine.path = stopPath.CGPath;
    self.stopLine.strokeColor = self.mainColor.CGColor;
    self.stopLine.fillColor = [UIColor clearColor].CGColor;
    self.stopLine.lineWidth = self.lineWidth ? self.lineWidth : 2.f;
    self.stopLine.lineCap = kCALineCapRound;
    self.stopLine.lineJoin = kCALineJoinMiter;
    self.stopLine.strokeStart = 0.f;
    self.stopLine.strokeEnd = 1.f;
    self.stopLine.opacity = 0.f;
    [self.layer addSublayer:self.stopLine];
}

- (void)setupOuterRound {
    CGFloat width = self.gop_width;
    
    UIBezierPath *outerPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2, width/2) radius:width/2 startAngle:-M_PI endAngle:M_PI clockwise:YES];
    self.outerRound.path = outerPath.CGPath;
    self.outerRound.anchorPoint = CGPointMake(0.5, 0.5);
    self.outerRound.fillColor = [UIColor clearColor].CGColor;
    self.outerRound.strokeColor = self.mainColor.CGColor;
    self.outerRound.lineWidth = self.lineWidth ? self.lineWidth : 2.f;
    self.outerRound.lineCap = kCALineCapRound;
    self.outerRound.lineJoin = kCALineJoinMiter;
    self.outerRound.opacity = 0.f;
    [self.layer addSublayer:self.outerRound];
}

- (void)setupInnerRound {
    CGFloat width = self.gop_width * GOPInnerFactor;
    CGRect rect = CGRectMake((self.gop_width-width)/2, (self.gop_width-width)/2, width, width);
    
    UIBezierPath *outerPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:width/2];
    self.innerRound.path = outerPath.CGPath;
    self.innerRound.anchorPoint = CGPointMake(0.5, 0.5);
    self.innerRound.fillColor = [UIColor clearColor].CGColor;
    self.innerRound.strokeColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor;
    self.innerRound.lineWidth = self.lineWidth ? self.lineWidth : 2.f;
    self.innerRound.lineCap = kCALineCapRound;
    self.innerRound.lineJoin = kCALineJoinMiter;
//    self.innerRound.opacity = 0.f;
    [self.layer addSublayer:self.innerRound];
}

@end
