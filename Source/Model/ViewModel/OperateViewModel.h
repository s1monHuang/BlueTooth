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

// 忘记密码
- (void)forgetPasswordWithEmail:(NSString *)email;

// 获取手机验证码
- (void)requestSmsCodeWithTelephone:(NSString *)telephone;
// 验证手机验证码
- (void)requestverifySmsCodeWithTelephone:(NSString *)telephone smsCode:(NSString *)smsCode;

// 获取排名数据
- (void)requestRankingListStartDate:(NSString *)startDate
                            endDate:(NSString *)endDate;

// 设置用户头像
- (void)setHeaderImage:(NSString *)headImage;

// 获取用户头像
- (void)getHeaderImage;

// 编辑用户信息
- (void)editWithUserNickName:(NSString *)nickName
                         sex: (NSString *)sex
                        high: (NSString *)high
                      weight: (NSString *)weight
                         age: (NSString *)age
                    stepLong: (NSString *)stepLong;
// 生产外设id
- (void)createExdeviceId;

// 绑定设备
- (void)bindExdevice:(NSString *)exDeviceId;

// 保存步数  例:2016-03-14
- (void)saveStepDataRecordDate:(NSString *)recordDate
                       stepNum: (NSString *)stepNum;

// 获取计步数据
- (void)getStepDataStartDate:(NSString *)startDate
                     endDate: (NSString *)endDate;

// 保存睡眠数据
- (void)saveSleepDataSleepDate:(NSString *)sleepDate
                       qsmTime: (NSString *)qsmTime
                       ssmTime: (NSString *)ssmTime;

// 获取睡眠数据
- (void)getSleepDataStartDate: (NSString *)startDate
                      endDate: (NSString *)endDate;

// 关联用户信息
- (void)relateUserInfoInviteCode: (NSString *)inviteCode;


@end
