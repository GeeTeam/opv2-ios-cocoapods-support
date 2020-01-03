//
//  GOPManager.h
//  GOPPhone
//
//  Created by NikoXu on 07/09/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GOPError.h"

@protocol GOPManagerDelegate;

typedef NS_ENUM(NSInteger, GOPPhoneNumEncryptOption) {
    GOPPhoneNumEncryptOptionNone = 0,   // none
    GOPPhoneNumEncryptOptionSha256      // sha256
};

typedef void(^GOPCompletion)(NSDictionary *dict);
typedef void(^GOPFailure)(NSError *error);

@interface GOPManager : NSObject

@property (nonatomic, weak) id<GOPManagerDelegate> delegate;

/**
 Diagnosis current network status.
 If OnePass could work, `diagnosisStatus` return YES.
 
 @discussion
 In the extreme situation, `diagnosisStatus` isn't reliable.
 */
@property (nonatomic, readonly, assign) BOOL diagnosisStatus;

/**
 Return current phone number.
 If encrypted, return encrypted phone number.
 
 @discussion
 Before OnePass callback, `currentPhoneNum` return
 original phone number.
 */
@property (nonatomic, readonly, copy) NSString *currentPhoneNum;

/**
 Phone number Encryption Option.
 If encrypted, it will be hard to debug. We recommend developers not to use this option.
 If you want use this option, you should register this feature through us first.
 */
@property (nonatomic, assign) GOPPhoneNumEncryptOption phoneNumEncryptOption;

/**
 Initializes and returns a newly allocated GOPManager object.
 
 @discussion Register customID from `geetest.com`, and configure your verifyUrl
             API base on Server SDK. Check Docs on `docs.geetest.com`. If OnePass
             fail, GOPManager will request SMS URL that you set.
 @param customID custom ID, nonull
 @param timeout timeout interval
 @return A initialized GOPManager object.
 */
- (instancetype)initWithCustomID:(NSString *)customID timeout:(NSTimeInterval)timeout;

/**
 Verify phone number through OnePass.
 See a sample result from `https://github.com/GeeTeam/gop-ios-sdk/blob/master/SDK/gop-ios-dev-doc.md#verifyphonenumcompletionfailure`
 
 @discussion Country Code `+86` Only. Regex rule `^1([3-9])\\d{9}$`.
             If you don't want to use validate, you should modify customID configuration
             by contacting geetest stuff first.
             QQ:2314321393 or E-mail: contact@geetest.com

 @param phoneNum phone number, nonull
 */
- (void)verifyPhoneNumber:(NSString *)phoneNum;
- (void)verifyPhoneNumber;

/**
 * @abstract 设置是否允许打印日志
 *
 * @param enabled YES，允许打印日志 NO，禁止打印日志
 */
+ (void)setLogEnabled:(BOOL)enabled;

/**
 * @abstract 是否允许打印日志
 *
 * @return YES，允许打印日志 NO，禁止打印日志
 */
+ (BOOL)isLogEnabled;

@end

/**
 Manager related to the operation of a verification that handle request
 directly to the delegate.
 */
@protocol GOPManagerDelegate <NSObject>

@required

- (void)gtOnePass:(GOPManager *)manager errorHandler:(GOPError *)error;

- (void)gtOnePass:(GOPManager *)manager didReceiveDataToVerify:(NSDictionary *)data;

@end
