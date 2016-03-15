//
//  OperateViewModel.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/5.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "OperateViewModel.h"

#import "UserOperator.h"

@interface OperateViewModel ()
@property (nonatomic, strong)UserOperator *userOperator;
@end

@implementation OperateViewModel

- (UserOperator *)userOperator
{
    if(!_userOperator){
        _userOperator = [UserOperator requestOperator];
    }
    return _userOperator;
}

// 登录
- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
{
    [self.userOperator loginWithUserName:userName password:password callBack:^(BOOL success, id responseObject, NSError *error) {
        self.startLoading = NO;
        if (success) {
            
            if([responseObject[@"retCode"] isEqualToString:@"000"])
            {
                if (self.finishHandler) self.finishHandler(YES, responseObject[@"userInfo"]);
            }else{
                if (self.finishHandler) self.finishHandler(NO, responseObject[@"retMsg"]);
            }
            
        } else {
            if (self.finishHandler) self.finishHandler(NO, errorMsg);
        }
    }];
    
}
// 自动登录
- (void)autoLoginWithTokenAnddevice:(NSString *)token
                           password:(NSString *)deviceId
{
    
}

// 注册
- (void)registerWithUserName:(NSString *)userName
                   passsword:(NSString *)password
{
    [self.userOperator registWithUserName:userName password:password callBack:^(BOOL success, id responseObject, NSError *error) {
        self.startLoading = NO;
        if (success) {
            
            if([responseObject[@"retCode"] isEqualToString:@"000"])
            {
                if (self.finishHandler) self.finishHandler(YES, responseObject[@"userId"]);
            }else{
                if (self.finishHandler) self.finishHandler(NO, responseObject[@"retMsg"]);
            }
            
        } else {
            if (self.finishHandler) self.finishHandler(NO, errorMsg);
        }
    }];
}

// 忘记密码
- (void)forgetPasswordWithEmail:(NSString *)email
{
    [self.userOperator forgetPasswordWithEmail:email callBack:^(BOOL success, id responseObject, NSError *error) {
        self.startLoading = NO;
        if (success) {
            
            if([responseObject[@"retCode"] isEqualToString:@"000"])
            {
                if (self.finishHandler) self.finishHandler(YES, responseObject[@"retMsg"]);
            }else{
//                if (self.finishHandler) self.finishHandler(NO, responseObject[@"retMsg"]);
            }
            
        } else {
            if (self.finishHandler) self.finishHandler(NO, errorMsg);
        }
    }];
}

// 获取手机验证码
- (void)requestSmsCodeWithTelephone:(NSString *)telephone
{
    
}
// 验证手机验证码
- (void)requestverifySmsCodeWithTelephone:(NSString *)telephone smsCode:(NSString *)smsCode
{
    
}

// 获取排名数据
- (void)requestRankingListStartDate:(NSString *)startDate
                            endDate:(NSString *)endDate
{
    [self.userOperator requestRankingListStartDate:startDate endDate:endDate callBack:^(BOOL success, id responseObject, NSError *error) {
        self.startLoading = NO;
        if (success) {
            
            if([responseObject[@"retCode"] isEqualToString:@"000"])
            {
                if (self.finishHandler) self.finishHandler(YES, responseObject[@"rankInfos"]);
            }else{
                if (self.finishHandler) self.finishHandler(NO, responseObject[@"retMsg"]);
            }
            
        } else {
            if (self.finishHandler) self.finishHandler(NO, errorMsg);
        }
    }];
}

// 设置用户头像
- (void)setHeaderImage:(NSString *)headImage
{
    
}

// 获取用户头像
- (void)getHeaderImage
{
    
}

// 编辑用户信息
- (void)editWithUserNickName:(NSString *)nickName
                         sex: (NSString *)sex
                        high: (NSString *)high
                      weight: (NSString *)weight
                         age: (NSString *)age
                    stepLong: (NSString *)stepLong
{
    [self.userOperator editWithUserNickName:nickName sex:sex high:high weight:weight age:age stepLong:stepLong callBack:^(BOOL success, id responseObject, NSError *error) {
        self.startLoading = NO;
        if (success) {
            
            if([responseObject[@"retCode"] isEqualToString:@"000"])
            {
                if (self.finishHandler) self.finishHandler(YES, responseObject[@"retMsg"]);
            }else{
                if (self.finishHandler) self.finishHandler(NO, responseObject[@"retMsg"]);
            }
            
        } else {
            if (self.finishHandler) self.finishHandler(NO, errorMsg);
        }
    }];
}
// 生产外设id
- (void)createExdeviceId
{
    [self.userOperator createExdeviceId:^(BOOL success, id responseObject, NSError *error) {
        self.startLoading = NO;
        if (success) {
            
            if([responseObject[@"retCode"] isEqualToString:@"000"])
            {
                if (self.finishHandler) self.finishHandler(YES, responseObject[@"exDeviceId"]);
            }else{
                if (self.finishHandler) self.finishHandler(NO, responseObject[@"retMsg"]);
            }
            
        } else {
            if (self.finishHandler) self.finishHandler(NO, errorMsg);
        }
    }];
}

// 绑定设备
- (void)bindExdevice:(NSString *)exDeviceId
{
    [self.userOperator bindExdevice:exDeviceId callBack:^(BOOL success, id responseObject, NSError *error) {
        self.startLoading = NO;
        if (success) {
            
            if([responseObject[@"retCode"] isEqualToString:@"000"])
            {
                if (self.finishHandler) self.finishHandler(YES, responseObject[@"retMsg"]);
            }else{
                if (self.finishHandler) self.finishHandler(NO, responseObject[@"retMsg"]);
            }
            
        } else {
            if (self.finishHandler) self.finishHandler(NO, errorMsg);
        }
    }];
}

// 保存步数
- (void)saveStepDataRecordDate:(NSString *)recordDate
                       stepNum: (NSString *)stepNum
{
    [self.userOperator saveStepDataRecordDate:recordDate stepNum:stepNum callBack:^(BOOL success, id responseObject, NSError *error) {
        self.startLoading = NO;
        if (success) {
            
            if([responseObject[@"retCode"] isEqualToString:@"000"])
            {
                if (self.finishHandler) self.finishHandler(YES, responseObject[@"retMsg"]);
            }else{
                if (self.finishHandler) self.finishHandler(NO, responseObject[@"retMsg"]);
            }
            
        } else {
            if (self.finishHandler) self.finishHandler(NO, errorMsg);
        }
    }];
}

// 获取计步数据
- (void)getStepDataStartDate:(NSString *)startDate
                     endDate: (NSString *)endDate
{
    [self.userOperator getStepDataStartDate:startDate endDate:endDate callBack:^(BOOL success, id responseObject, NSError *error) {
        self.startLoading = NO;
        if (success) {
            
            if([responseObject[@"retCode"] isEqualToString:@"000"])
            {
                if (self.finishHandler) self.finishHandler(YES, responseObject[@"stepInfos"]);
            }else{
                if (self.finishHandler) self.finishHandler(NO, responseObject[@"retMsg"]);
            }
            
        } else {
            if (self.finishHandler) self.finishHandler(NO, errorMsg);
        }
    }];
}

// 保存睡眠数据
- (void)saveSleepDataSleepDate:(NSString *)sleepDate
                       gsmTime: (NSString *)gsmTime
                       ssmTime: (NSString *)ssmTime
{
    [self.userOperator saveSleepDataSleepDate:sleepDate gsmTime:gsmTime ssmTime:ssmTime callBack:^(BOOL success, id responseObject, NSError *error) {
        self.startLoading = NO;
        if (success) {
            
            if([responseObject[@"retCode"] isEqualToString:@"000"])
            {
                if (self.finishHandler) self.finishHandler(YES, responseObject[@"retMsg"]);
            }else{
                if (self.finishHandler) self.finishHandler(NO, responseObject[@"retMsg"]);
            }
            
        } else {
            if (self.finishHandler) self.finishHandler(NO, errorMsg);
        }
    }];
}

// 获取睡眠数据
- (void)getSleepDataStartDate: (NSString *)startDate
                      endDate: (NSString *)endDate
{
    [self.userOperator getSleepDataStartDate:startDate endDate:endDate callBack:^(BOOL success, id responseObject, NSError *error) {
        self.startLoading = NO;
        if (success) {
            
            if([responseObject[@"retCode"] isEqualToString:@"000"])
            {
                if (self.finishHandler) self.finishHandler(YES, responseObject[@"sleepInfos"]);
            }else{
                if (self.finishHandler) self.finishHandler(NO, responseObject[@"retMsg"]);
            }
            
        } else {
            if (self.finishHandler) self.finishHandler(NO, errorMsg);
        }
    }];
}

// 关联用户信息
- (void)relateUserInfoInviteCode: (NSString *)inviteCode
{
    [self.userOperator relateUserInfoInviteCode:inviteCode callBack:^(BOOL success, id responseObject, NSError *error) {
        self.startLoading = NO;
        if (success) {
            
            if([responseObject[@"retCode"] isEqualToString:@"000"])
            {
                if (self.finishHandler) self.finishHandler(YES, responseObject[@"retMsg"]);
            }else{
                if (self.finishHandler) self.finishHandler(NO, responseObject[@"retMsg"]);
            }
            
        } else {
            if (self.finishHandler) self.finishHandler(NO, errorMsg);
        }
    }];
}


@end
