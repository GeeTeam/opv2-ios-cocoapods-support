//
//  GOPErrorInfoView.m
//  OnePassLoading
//
//  Created by NikoXu on 24/11/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import "GOPErrorInfoView.h"

@interface GOPErrorInfoView ()

@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UILabel *label2;

@end

@implementation GOPErrorInfoView

- (instancetype)initWithFrame:(CGRect)frame error:(NSError *)error {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
        
        [self setupLabels:error];
    }
    
    return self;
}

- (void)setupLabels:(NSError *)error {
    
    if (!error) return;
    
    self.label1 = [[UILabel alloc] initWithFrame:CGRectZero];
    self.label2 = [[UILabel alloc] initWithFrame:CGRectZero];
    
    self.label1.text = [NSString stringWithFormat:@"%ld", (long)error.code];
    self.label2.text = @"验证故障, 请关闭验证";
    
    self.label1.font = [UIFont boldSystemFontOfSize:10.0];
    self.label2.font = [UIFont boldSystemFontOfSize:10.0];
    
    self.label1.textColor = [UIColor blackColor];
    self.label2.textColor = [UIColor blackColor];
    
    [self.label1 sizeToFit];
    [self.label2 sizeToFit];
    
    [self.label1 setCenter:CGPointMake(self.label1.bounds.size.width/2, self.bounds.size.height/2)];
    [self.label2 setCenter:CGPointMake(self.bounds.size.width - self.label2.bounds.size.width/2, self.bounds.size.height/2)];
    
    [self addSubview:self.label1];
    [self addSubview:self.label2];
}

@end
