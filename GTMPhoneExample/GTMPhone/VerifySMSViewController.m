//
//  VerifySMSViewController.m
//  GTMPhone
//
//  Created by NikoXu on 21/09/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import "VerifySMSViewController.h"
#import "ResultViewController.h"

#import "TipsView.h"
#import "UIView+GTM.h"
#import "UIButton+GTM.h"

@interface VerifySMSViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *smsCodeTextField;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation VerifySMSViewController

- (IBAction)back:(id)sender {
    if (self.timer) [self.timer invalidate];
    if ([self.smsCodeTextField canResignFirstResponder]) {
        [self.smsCodeTextField resignFirstResponder];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextStep:(id)sender {
    if ([self.smsCodeTextField canResignFirstResponder]) {
        [self.smsCodeTextField resignFirstResponder];
    }
    [self handleSMS];
}

- (void)dealloc {
    if (self.timer) [self.timer invalidate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.smsCodeTextField.delegate = self;
    self.timerLabel.text = @"(60秒)";
    self.phoneNumLabel.text = self.phoneNum;
    
    if (self.timer) [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimerLabel) userInfo:nil repeats:YES];
    [self.timer fire];
    
    if ([self.smsCodeTextField canBecomeFirstResponder]) {
        [self.smsCodeTextField becomeFirstResponder];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.nextButton gtm_removeIndicator];
}

- (void)handleSMS {
    NSString *smsCode = self.smsCodeTextField.text;
    if (smsCode.length != 6) {
        if (!self.timer.isValid) {
            if (_delegate && [_delegate respondsToSelector:@selector(smsVCWillResend)]) {
                [_delegate smsVCWillResend];
                self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimerLabel) userInfo:nil repeats:YES];
                self.timerLabel.text = @"(60秒)";
                [self.timer fire];
            }
        }
        [self.smsCodeTextField gtm_shake:9 witheDelta:2.f speed:0.1f completion:nil];
        return;
    }
    
    [self.nextButton gtm_showIndicator];
    
    [self checkSMS:smsCode completion:^(NSDictionary *dict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.nextButton gtm_removeIndicator];
            [self dismissViewControllerAnimated:YES completion:^{
                if (_delegate && [_delegate respondsToSelector:@selector(smsVCDidSuccess:)]) {
                    [_delegate smsVCDidSuccess:dict];
                }
            }];
        });
    } failure:^(NSError *error) {
        [self.timer invalidate];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.nextButton gtm_removeIndicator];
        });
        [TipsView showTipOnKeyWindow:error.description fontSize:14.0];
        NSLog(@"error: %@", error);
    }];
}

- (void)checkSMS:(NSString *)message_number completion:(void (^)(NSDictionary *))completion failure:(void (^)(NSError *))failure {
    NSURL *url = [NSURL URLWithString:@"http://onepass.geetest.com/v2.0/check_message"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    NSDictionary *dict = @{@"process_id": self.processID, @"message_number": message_number};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    req.HTTPBody = data;
    NSURLSessionTask *task = [NSURLSession.sharedSession dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failure(error);
            return;
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([dict[@"result"] isEqual:@(YES)]) {
            completion(dict);
        } else {
            NSError *e = [NSError errorWithDomain:@"com.xxx.demo" code:-1 userInfo:@{NSLocalizedDescriptionKey : dict.description}];
            failure(e);
        }
    }];
    [task resume];
}

- (void)creatSubviewOnSMSCodeView {
    
}

- (void)updateTimerLabel {
    NSCharacterSet *cSet = [NSCharacterSet characterSetWithCharactersInString:@"(秒)"];
    NSString *timeStr = [self.timerLabel.text stringByTrimmingCharactersInSet:cSet];
    int timeCount = [timeStr intValue];
    timeCount--;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (timeCount > 0) {
            self.timerLabel.text = [NSString stringWithFormat:@"(%d秒)", timeCount];
        }
        else {
            self.timerLabel.text = @"";
            [self.timer invalidate];
            self.nextButton.titleLabel.text = @"再发送一次";
        }
    });
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length == 6) {
        [self handleSMS];
        if ([textField canResignFirstResponder]) {
            [textField resignFirstResponder];
        }
        return YES;
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
