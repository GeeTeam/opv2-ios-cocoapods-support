//
//  GOPProgressView.h
//  OnePassLoading
//
//  Created by NikoXu on 10/11/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GOPProgressState) {
    GOPProgressStateCaptcha,
    GOPProgressStateOnePass,
    GOPProgressStateOnePassSuccess,
    GOPProgressStateOnePassFail,
    GOPProgressStateSMS,
    GOPProgressStateError
};

@interface GOPProgressView : UIView

@property (nonatomic, assign) GOPProgressState state;

@property (nonatomic, assign) CGFloat lineWidth;

- (instancetype)initWithFrame:(CGRect)frame mainColor:(UIColor *)color;

- (void)updateProgressState:(GOPProgressState)state withError:(NSError *)error;

@end
