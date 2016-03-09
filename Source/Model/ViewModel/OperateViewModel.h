//
//  OperateViewModel.h
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/5.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewModel.h"

@interface OperateViewModel : BaseViewModel

// 登录
- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password;
// 自动登录
- (void)autoLoginWithTokenAnddevice:(NSString *)token
                           password:(NSString *)deviceId;

// 注册
- (void)registerWithUserName:(NSString *)userName
                   passsword:(NSString *)password;
// 获取手机验证码
- (void)requestSmsCodeWithTelephone:(NSString *)telephone;
// 验证手机验证码
- (void)requestverifySmsCodeWithTelephone:(NSString *)telephone smsCode:(NSString *)smsCode;

// 获取排名数据
- (void)requestRankingList;

@end
