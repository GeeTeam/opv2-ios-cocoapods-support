//
//  CABasicAnimation+GOP.m
//  OnePassLoading
//
//  Created by NikoXu on 22/11/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import "CABasicAnimation+GOP.h"

@implementation CABasicAnimation (GOP)

+ (CABasicAnimation *)gop_animationWithBeginTime:(NSTimeInterval)beginTime duration:(NSTimeInterval)duration fromValue:(id)fromValue toValue:(id)toValue autoreversed:(BOOL)reversed keyPath:(NSString *)keyPath {
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.duration = duration;
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    animation.beginTime = beginTime;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    if (reversed) {
        animation.autoreverses = YES;
        animation.repeatCount = HUGE_VALF;
    }
    else {
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
    }
    
    return animation;
}

@end
