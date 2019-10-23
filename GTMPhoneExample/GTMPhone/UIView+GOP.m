//
//  UIView+GOP.m
//  OnePassLoading
//
//  Created by NikoXu on 14/11/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import "UIView+GOP.h"

@implementation UIView (GOP)

@dynamic gop_width, gop_height;

- (CGFloat)gop_width {
    return self.bounds.size.width;
}

- (CGFloat)gop_height {
    return self.bounds.size.height;
}

@end
