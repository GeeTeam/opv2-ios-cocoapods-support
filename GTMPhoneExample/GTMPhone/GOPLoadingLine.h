//
//  GOPLoadingLine.h
//  OnePassLoading
//
//  Created by NikoXu on 24/11/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOPLoadingLine : UIView

@property (nonatomic, assign) CGFloat lineWidth;

- (instancetype)initWithFrame:(CGRect)frame mainColor:(UIColor *)color;

- (void)finish:(void(^)(void))completion;

@end
