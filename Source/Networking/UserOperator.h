//
//  UserOperator.h
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/5.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "BaseRequestOperator.h"

@interface UserOperator : BaseRequestOperator

// 登录
- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
                 callBack:(BaseNetworkCallBack)callBack;

// 注册
- (void)registWithUserName:(NSString *)userName
                 password:(NSString *)password
                 callBack:(BaseNetworkCallBack)callBack;

// 忘记密码
- (void)forgetPasswordWithEmail:(NSString *)email
                       callBack:(BaseNetworkCallBack)callBack;

// 获取排名数据
- (void)requestRankingListStartDate:(NSString *)startDate
                            endDate:(NSString *)endDate
                           callBack:(BaseNetworkCallBack)callBack;

// 设置用户头像
- (void)setHeaderImage:(NSString *)headImage
              callBack:(BaseNetworkCallBack)callBack;

// 获取用户头像
- (void)getHeaderImage:(BaseNetworkCallBack)callBack;


// 编辑用户信息
- (void)editWithUserNickName:(NSString *)nickName
                         sex: (NSString *)sex
                        high: (NSString *)high
                      weight: (NSString *)weight
                         age: (NSString *)age
                    stepLong: (NSString *)stepLong
                    callBack:(BaseNetworkCallBack)callBack;
// 生产外设id
- (void)createExdeviceId:(BaseNetworkCallBack)callBack;

// 绑定设备
- (void)bindExdevice:(NSString *)exDeviceId
            callBack:(BaseNetworkCallBack)callBack;

// 保存步数
- (void)saveStepDataRecordDate:(NSString *)recordDate
             stepNum: (NSString *)stepNum
            callBack:(BaseNetworkCallBack)callBack;

// 获取计步数据
- (void)getStepDataStartDate:(NSString *)startDate
            endDate: (NSString *)endDate
           callBack:(BaseNetworkCallBack)callBack;

// 保存睡眠数据
- (void)saveSleepDataSleepDate:(NSString *)sleepDate
              qsmTime: (NSString *)qsmTime
              ssmTime: (NSString *)ssmTime
             callBack:(BaseNetworkCallBack)callBack;

// 获取睡眠数据
- (void)getSleepDataStartDate: (NSString *)startDate
             endDate: (NSString *)endDate
            callBack:(BaseNetworkCallBack)callBack;

// 关联用户信息
- (void)relateUserInfoInviteCode: (NSString *)inviteCode
              callBack:(BaseNetworkCallBack)callBack;

@end
