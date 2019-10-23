//
//  GOPIndicatorView.h
//  OnePassLoading
//
//  Created by NikoXu on 09/11/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GOPIndicatorState) {
    GOPIndicatorStateLoading,
    GOPIndicatorStateLooping,
    GOPIndicatorStateFinish,
    GOPIndicatorStateStop
};

@interface GOPIndicatorView : UIView

@property (nonatomic, assign) GOPIndicatorState state;
@property (nonatomic, assign) CGFloat lineWidth;

- (instancetype)initWithFrame:(CGRect)frame mainColor:(UIColor *)color;

- (void)load:(void(^)(void))completion;
- (void)loop;
- (void)finish:(void(^)(void))completion;
- (void)stop:(void(^)(void))completion;

@end
