//
//  CABasicAnimation+GOP.h
//  OnePassLoading
//
//  Created by NikoXu on 22/11/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CABasicAnimation (GOP)

+ (CABasicAnimation *)gop_animationWithBeginTime:(NSTimeInterval)beginTime duration:(NSTimeInterval)duration fromValue:(id)fromValue toValue:(id)toValue autoreversed:(BOOL)reversed keyPath:(NSString *)keyPath;

@end
