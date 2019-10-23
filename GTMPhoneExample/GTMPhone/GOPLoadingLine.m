//
//  GOPLoadingLine.m
//  OnePassLoading
//
//  Created by NikoXu on 24/11/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import "GOPLoadingLine.h"
#import "UIView+GOP.h"
#import "CABasicAnimation+GOP.h"

@interface GOPLoadingLine ()

@property (nonatomic, strong) UIColor *mainColor;

@property (nonatomic, strong) CAShapeLayer *line;

@end

@implementation GOPLoadingLine

- (instancetype)initWithFrame:(CGRect)frame mainColor:(UIColor *)color {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
        self.mainColor = color;
        
        self.line = [[CAShapeLayer alloc] init];
        
        [self setupLine];
    }
    
    return self;
}

- (void)finish:(void (^)(void))completion {
    self.line.opacity = 1.f;
    
    CABasicAnimation *stroke = [CABasicAnimation gop_animationWithBeginTime:CACurrentMediaTime() duration:0.3 fromValue:@(0.f) toValue:@(1.f) autoreversed:NO keyPath:@"strokeEnd"];
    
    [self.line addAnimation:stroke forKey:@"stroke"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) completion();
    });
}

- (void)setupLine {
    CGFloat width = self.gop_width;
    CGFloat height = self.gop_height;
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    
    [linePath moveToPoint:CGPointMake(0, height/2)];
    [linePath addLineToPoint:CGPointMake(width, height/2)];
    
    self.line.frame = self.bounds;
    self.line.anchorPoint = CGPointMake(0.5, 0.5);
    self.line.path = linePath.CGPath;
    self.line.strokeColor = self.mainColor.CGColor;
    self.line.fillColor = [UIColor clearColor].CGColor;
    self.line.lineWidth =  self.lineWidth ? self.lineWidth : 2.0f;
//    self.line.lineCap = kCALineCapSquare;
//    self.line.lineJoin = kCALineJoinMiter;
    self.line.strokeStart = 0.f;
    self.line.strokeEnd = 1.f;
    self.line.opacity = 0.f;
    [self.layer addSublayer:self.line];
}

@end
