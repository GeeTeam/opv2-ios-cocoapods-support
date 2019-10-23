//
//  GOPProgressView.m
//  OnePassLoading
//
//  Created by NikoXu on 10/11/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import "GOPProgressView.h"
#import "GOPLoadingLine.h"
#import "GOPIndicatorView.h"
#import "GOPErrorInfoView.h"
#import "UIView+GOP.h"

@interface GOPProgressView ()

@property (nonatomic, strong) UIColor *mainColor;

@property (nonatomic, strong) GOPLoadingLine *line1;
@property (nonatomic, strong) GOPLoadingLine *line2;
@property (nonatomic, strong) GOPLoadingLine *line3;

@property (nonatomic, strong) GOPIndicatorView *indicator1;
@property (nonatomic, strong) GOPIndicatorView *indicator2;
@property (nonatomic, strong) GOPErrorInfoView *errorView;

@end

@implementation GOPProgressView

- (instancetype)initWithFrame:(CGRect)frame mainColor:(UIColor *)color {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.mainColor = color;
        self.backgroundColor = [UIColor whiteColor];
        
        self.layer.cornerRadius = 2.f;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor;
        [self setClipsToBounds:YES];
        
        [self setupProgressView];
    }
    
    return self;
}

- (void)updateProgressState:(GOPProgressState)state withError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (state) {
            case GOPProgressStateCaptcha:
            {
                [self.line1 finish:^{
                    [self.indicator1 load:nil];
                    [self.indicator1 loop];
                }];
            }
                break;
            case GOPProgressStateOnePass:
            {
                [self.indicator1 finish:^{
                    [self.line2 finish:^{
                        [self.indicator2 load:nil];
                        [self.indicator2 loop];
                    }];
                }];
            }
                break;
            case GOPProgressStateSMS:
            {
                [self.indicator2 stop:nil];
                [self.line3 finish:^{
                    [self removeFromSuperview];
                }];
            }
                break;
            case GOPProgressStateOnePassSuccess:
            {
                [self.indicator2 finish:nil];
                [self.line3 finish:^{
                    [self removeFromSuperview];
                }];
            }
                break;
            case GOPProgressStateOnePassFail:
            {
                [self.indicator2 stop:^{
                    [self.line3 finish:^{
                        [self removeFromSuperview];
                    }];
                }];
            }
            case GOPProgressStateError:
            {
                if (error) {
                    if (self.errorView) [self.errorView removeFromSuperview];
                    self.errorView = [[GOPErrorInfoView alloc] initWithFrame:CGRectMake(0, self.gop_height, self.gop_width, self.gop_height * 0.2) error:error];
                    [self addSubview:self.errorView];
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        [self setBounds:CGRectMake(0, 0, self.gop_width, self.gop_height * 1.2)];
                    } completion:^(BOOL finished) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self removeFromSuperview];
                        });
                    }];
                }
                else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self removeFromSuperview];
                    });
                }
            }
                break;
            default:
                break;
        }
    });
}

- (void)setupProgressView {
    
    [self setupImages];// 0.3
    [self setupLines];// 0.56
    [self setupIndocator];// 0.56
    [self setupLabel];// 0.8
}

- (void)setupImages {
    CGFloat width = self.gop_width;
    CGFloat height = self.gop_height;
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gop_people"]];
    [imageView1 setCenter:CGPointMake(width * 0.3, height * 0.3)];
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gop_basestation"]];
    [imageView2 setCenter:CGPointMake(width * 0.7, height * 0.3)];
    
    [self addSubview:imageView1];
    [self addSubview:imageView2];
}

- (void)setupLines {
    CGFloat width = self.gop_width;
    CGFloat height = self.gop_height;
    
    CGFloat lineWidth = self.lineWidth ? self.lineWidth : 2.f;
    
    self.line1 = [[GOPLoadingLine alloc] initWithFrame:CGRectMake(0, height * 0.56 - lineWidth/2, width * 0.3, lineWidth) mainColor:self.mainColor];
    self.line2 = [[GOPLoadingLine alloc] initWithFrame:CGRectMake(width * 0.3, height * 0.56 - lineWidth/2, width * 0.4, lineWidth) mainColor:self.mainColor];
    self.line3 = [[GOPLoadingLine alloc] initWithFrame:CGRectMake(width * 0.7, height * 0.56 - lineWidth/2, width * 0.3, lineWidth) mainColor:self.mainColor];
    
    [self addSubview:self.line1];
    [self addSubview:self.line2];
    [self addSubview:self.line3];
}

- (void)setupIndocator {
    CGFloat width = self.gop_width;
    CGFloat height = self.gop_height;
    
    self.indicator1 = [[GOPIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 14, 14) mainColor:self.mainColor];
    [self.indicator1 setCenter:CGPointMake(width * 0.3, height * 0.56)];
    
    self.indicator2 = [[GOPIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 15, 15) mainColor:self.mainColor];
    [self.indicator2 setCenter:CGPointMake(width * 0.7, height * 0.56)];
    
    [self addSubview:self.indicator1];
    [self addSubview:self.indicator2];
}

- (void)setupLabel {
    CGFloat width = self.gop_width;
    CGFloat height = self.gop_height;
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectZero];
    
    label1.text = @"人机验证";
    label1.textColor = [UIColor blackColor];
    label1.font = [UIFont boldSystemFontOfSize:12];
    [label1 sizeToFit];
    [label1 setCenter:CGPointMake(width * 0.3, height * 0.8)];
    label2.text = @"网关验证";
    label2.textColor = [UIColor blackColor];
    label2.font = [UIFont boldSystemFontOfSize:12.0];
    [label2 sizeToFit];
    [label2 setCenter:CGPointMake(width * 0.7, height * 0.8)];
    
    
    [self addSubview:label1];
    [self addSubview:label2];
}

@end
