//
//  PhoneNumViewController.m
//  GTMPhone
//
//  Created by NikoXu on 21/09/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import "PhoneNumViewController.h"
#import "VerifySMSViewController.h"
#import "ResultViewController.h"

#import "GOPProgressView.h"
#import "TipsView.h"

#import "GT3CaptchaEX.h"

#import "UIButton+GTM.h"
#import "UIView+GTM.h"

@import GTOnePass;

////网站主部署的用于test-Button的register接口
//#define API1 @"http://dev.tongbancheng.com/api/verify/geetest/start_captcha?access_token=8b5efe542086595cb5c25426ccb20625&t=1512116140"
////网站主部署的用于test-Button的validate接口
//#define API2 @"http://www.geetest.com/demo/gt/validate-fullpage"

//网站主部署的用于test-Button的register接口
#define API1 @"http://www.geetest.com/demo/gt/register-fullpage"
//网站主部署的用于test-Button的validate接口
#define API2 @"http://www.geetest.com/demo/gt/validate-fullpage"

////网站主部署的用于test-Button的register接口
//#define API1 @"http://www.geetest.com/demo/gt/register-test"
////网站主部署的用于test-Button的validate接口
//#define API2 @"http://www.geetest.com/demo/gt/validate-test"

//网站主部署的ONEPASS的校验接口
#define verify_url @"http://onepass.geetest.com/v2.0/result"
//#define verify_url @"http://113.57.172.158:8886/check_gateway.php"

#define CUSTOMID @"87fa688dd5ea4867392ea4e5f0965fee"

@interface PhoneNumViewController () <UITextFieldDelegate, SMSCodeDelegate, ResultVCDelegate, GOPManagerDelegate, GT3CaptchaManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) NSString *message_id;

@property (nonatomic, strong) GT3CaptchaEX *captchaEx;
@property (nonatomic, strong) GOPManager *manager;

@property (nonatomic, strong) GOPProgressView *progressView;
@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation PhoneNumViewController

- (IBAction)back:(id)sender {
    if ([self.phoneNumTextField canResignFirstResponder]) {
        [self.phoneNumTextField resignFirstResponder];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextStep:(id)sender {
    [self verifyPhoneNum];
    if ([self.phoneNumTextField canResignFirstResponder]) {
        [self.phoneNumTextField resignFirstResponder];
    }
}

- (GOPManager *)manager {
    if (!_manager) {
#ifdef DEBUG
        _manager = [[GOPManager alloc] initWithCustomID:CUSTOMID timeout:10.0];
//        _manager = [[GOPManager alloc] initWithCustomID:@"cf26aee34febdc6da82004e04d419037" verifyUrl:verify_url timeout:10.0];
#else
        _manager = [[GOPManager alloc] initWithCustomID:CUSTOMID timeout:10.0];
#endif
        //"63289cec84eecde1076eb3fa0d70db77", "7591d0f44d4c265c8441e99c748d936b","19da67fb88d37a63ecf7eba9509a5083","fd2cf5e6589a7ceccbc1cc57f6b299a4"
        _manager.delegate = self;
//        _manager.phoneNumEncryptOption = GOPPhoneNumEncryptOptionSha256;
    }
    
    return _manager;
}

- (void)dealloc {
    [self.captchaEx stopGT3Captcha];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.captchaEx = [[GT3CaptchaEX alloc] initWithApi1:API1 api2:API2 timeout:10.0];
    self.captchaEx.manager.delegate = self;
    [self.captchaEx registerGT3Captcha];
    
    if ([self.type isEqualToString:@"login"]) {
        self.titleLabel.text = @"请登录";
    }
    
    if ([self.type isEqualToString:@"register"]) {
        self.titleLabel.text = @"请注册";
    }
    
    if ([self.phoneNumTextField canBecomeFirstResponder]) {
        [self.phoneNumTextField becomeFirstResponder];
    }
    self.phoneNumTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
#ifdef LOADING
#else
    [self.nextButton gtm_removeIndicator];
#endif
}

- (void)verifyPhoneNum {
    
    NSString *num = self.phoneNumTextField.text;
    if (![self checkPhoneNumFormat:num]) {
        self.phoneNumTextField.text = nil;
        [self.phoneNumTextField gtm_shake:9 witheDelta:2.f speed:0.1 completion:nil];
#ifdef LOADING
        [self.progressView removeFromSuperview];
#endif
        [TipsView showTipOnKeyWindow:@"不合法的手机号"];
        return;
    }

    [self startCaptcha];
}

- (void)startCaptcha {
#ifdef LOADING
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    self.progressView = [[GOPProgressView alloc] initWithFrame:CGRectMake(0, 0, 200, 120) mainColor:[UIColor colorWithRed:0.47 green:0.37 blue:1 alpha:1]];
    [keyWindow addSubview:self.progressView];
    [self.progressView setCenter:keyWindow.center];
    
    [self.progressView updateProgressState:GOPProgressStateCaptcha withError:nil];
#else
    [self.nextButton gtm_showIndicator];
#endif
    [self.captchaEx startGT3Captcha];
}

- (void)startOnePass:(NSString *)validate {
    NSString *num = self.phoneNumTextField.text;
    
    if (![self checkPhoneNumFormat:num]) {// check phone num, country code
        self.phoneNumTextField.text = nil;
        [self.phoneNumTextField gtm_shake:9 witheDelta:2.f speed:0.1 completion:nil];
#ifdef LOADING
        [self.progressView removeFromSuperview];
#endif
        [TipsView showTipOnKeyWindow:@"不合法的手机号"];
        return;
    }

    if (!self.manager.diagnosisStatus) {// check onepass network
#ifdef LOADING
        [self.progressView removeFromSuperview];
#endif
        [TipsView showTipOnKeyWindow:@"OnePass需要您的数据网络支持。如果确认已开启数据网络, 可能是您当前的网络不被支持。"];
        return;
    }
    
#ifdef LOADING
    [self.progressView updateProgressState:GOPProgressStateOnePass withError:nil];
#endif
    
    [self.manager verifyPhoneNumber:num];
}

- (BOOL)checkPhoneNumFormat:(NSString *)num {
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,147,148,150,151,152,157,158,159,172,178,182,183,184,187,188,198
     * 联通：130,131,132,145,146,152,155,156,166,171,175,176,185,186
     * 电信：133,1349,153,173,174,177,180,181,189,199
     */
    
    /**
     * 宽泛的手机号过滤规则
     */
    NSString * MOBILE = @"^1([3-9])\\d{9}$";
    
    /**
     * 虚拟运营商: Virtual Network Operator
     * 不支持
     */
    NSString * VNO = @"^170\\d{8}$";
    
    /**
     * 中国移动：China Mobile
     * 134[0-8],135,136,137,138,139,147,150,151,152,157,158,159,172,178,182,183,184,187,188
     */
    
    NSString * CM = @"^1(34[0-8]|(3[5-9]|4[78]|5[0-27-9]|7[28]|8[2-478]|98)\\d)\\d{7}$";
    
    /**
     * 中国联通：China Unicom
     * 130,131,132,152,155,156,176,185,186
     */
    
    NSString * CU = @"^1(3[0-2]|45|5[256]|7[156]|8[56])\\d{8}$";
    
    /**
     * 中国电信：China Telecom
     * 133,1349,153,173,177,180,181,189
     */
    
    NSString * CT = @"^1((33|53|7[347]|8[019]|99)[0-9]|349)\\d{7}$";
    
    NSPredicate *regexTestMobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];

    NSPredicate *regexTestVNO = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", VNO];
    
    NSPredicate *regexTestCM = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    
    NSPredicate *regexTestCU = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    
    NSPredicate *regexTestCT = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if ([regexTestMobile evaluateWithObject:num] == YES &&
        (([regexTestCM evaluateWithObject:num] == YES) ||
        ([regexTestCT evaluateWithObject:num] == YES) ||
        ([regexTestCU evaluateWithObject:num] == YES)) &&
        [regexTestVNO evaluateWithObject:num] == NO) {
        return YES;
    }
    else return NO;
}

#pragma mark GOPManagerDelegate

- (void)gtOnePass:(GOPManager *)manager didReceiveDataToVerify:(NSDictionary *)data {
    NSMutableDictionary *mdict = [data mutableCopy];
    mdict[@"id_2_sign"] = CUSTOMID;
    NSURL *url = [NSURL URLWithString:verify_url];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    req.HTTPBody = [NSJSONSerialization dataWithJSONObject:mdict options:0 error:nil];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (nil != data) {
            NSLog(@"result: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:nil];
            if ([result[@"status"] isEqual:@(200)] && [result[@"result"] isEqual:@"0"]) {
#ifdef LOADING
                [self.progressView updateProgressState:GOPProgressStateOnePassSuccess withError:nil];
#else
                [self.nextButton gtm_removeIndicator];
#endif
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                ResultViewController *vc = [sb instantiateViewControllerWithIdentifier:@"result"];
                vc.delegate = self;
                vc.type = self.type;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self presentViewController:vc animated:YES completion:nil];
                });
            } else {
                [self sendSMS];
            }
        } else {
            [self sendSMS];
        }
    }];
    [task resume];
}

- (void)gtOnePass:(GOPManager *)manager errorHandler:(GOPError *)error {
    [self sendSMS];
}

- (void)sendSMS {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url = [NSURL URLWithString:@"http://onepass.geetest.com/v2.0/send_message"];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        req.HTTPMethod = @"POST";
        NSString *phone = self.phoneNumTextField.text;
        NSNumber *phoneNumber = @(phone.integerValue);
        NSDictionary *dict = @{@"phone": phoneNumber};
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        req.HTTPBody = data;
        
        NSURLSessionTask *dataTask = [NSURLSession.sharedSession dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString *pid = dict[@"process_id"];
            if (pid) {
                [self.progressView updateProgressState:GOPProgressStateSMS withError:nil];
                
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                VerifySMSViewController *vc = [sb instantiateViewControllerWithIdentifier:@"verifySMS"];
                vc.phoneNum = phone;
                vc.processID = pid;
                vc.delegate = self;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self presentViewController:vc animated:YES completion:nil];
                });
            } else {
#ifdef LOADING
            [self.progressView updateProgressState:GOPProgressStateError withError:error];
#else
            [self.nextButton gtm_removeIndicator];
#endif
            }
        }];
        [dataTask resume];
    });
}

#pragma mark GT3CaptchaManager

- (void)gtCaptcha:(GT3CaptchaManager *)manager errorHandler:(GT3Error *)error {
#ifdef LOADING
    [self.progressView updateProgressState:GOPProgressStateError withError:error];
#else
    [TipsView showTipOnKeyWindow:error.description];
#endif
    NSLog(@"Captcha error: %@", error.description);
}

// disable secondary validate when using OnePass
- (BOOL)shouldUseDefaultSecondaryValidate:(GT3CaptchaManager *)manager {
    return NO;
}

- (void)gtCaptcha:(GT3CaptchaManager *)manager didReceiveSecondaryCaptchaData:(NSData *)data response:(NSURLResponse *)response error:(GT3Error *)error decisionHandler:(void (^)(GT3SecondaryCaptchaPolicy))decisionHandler {
    // If `shouldUseDefaultSecondaryValidate:` return NO, do nothing here
    
}

// put captcha result into OnePass
- (void)gtCaptcha:(GT3CaptchaManager *)manager didReceiveCaptchaCode:(NSString *)code result:(NSDictionary *)result message:(NSString *)message {
    
    if (![code isEqualToString:@"1"]) return;
    
    NSString *validate = [result objectForKey:@"geetest_validate"];
    
    if (!validate || validate.length != 32) return;
    
    [self startOnePass:validate];
}

- (void)gtCaptcha:(GT3CaptchaManager *)manager willSendRequestAPI1:(NSURLRequest *)originalRequest withReplacedHandler:(void (^)(NSURLRequest *))replacedHandler {
    // add timestamp to api1
    NSMutableURLRequest *mRequest = [originalRequest mutableCopy];
    
    NSURLComponents *comp = [[NSURLComponents alloc] initWithString:mRequest.URL.absoluteString];
    NSMutableArray *items = [comp.queryItems mutableCopy];
    [items enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURLQueryItem *item = (NSURLQueryItem *)obj;
        if (item.name && [item.name isEqualToString:@"t"]) {
            NSString *time = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
            [items removeObject:obj];
            NSURLQueryItem *new = [[NSURLQueryItem alloc] initWithName:@"t" value:time];
            [items addObject:new];
        }
    }];
    comp.queryItems = items;
    mRequest.URL = comp.URL;
    
    replacedHandler(mRequest);
}

#pragma mark DEMO Delegate

- (void)smsVCDidSuccess:(NSDictionary *)dict {
    
#ifdef LOADING
#else
    [self.nextButton gtm_removeIndicator];
#endif
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ResultViewController *vc = [sb instantiateViewControllerWithIdentifier:@"result"];
    vc.delegate = self;
    vc.type = self.type;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)smsVCWillResend {
    [self sendSMS];
}

- (void)resultVCDidReturn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length == 11) {
        [self verifyPhoneNum];
        if ([textField canResignFirstResponder]) {
            [textField resignFirstResponder];
        }
        return YES;
    }
    else return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
