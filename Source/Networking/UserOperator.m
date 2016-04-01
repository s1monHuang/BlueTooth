//
//  UserOperator.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/5.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "UserOperator.h"

@implementation UserOperator

// 登录
- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
                 callBack:(BaseNetworkCallBack)callBack
{
    NSString *path = @"rest/ring/login";
    NSDictionary *params = @{@"email" : userName,
                             @"password" :  password
                             };
    
    [self requestNetworkWithPath:path parameters:params callBackBlock:^(BOOL success, id responseObject, NSError *error) {
        if (success) {
            if (callBack) callBack(YES, responseObject, nil);
        } else {
            if (callBack) callBack(NO, responseObject, error);
        }
    }];
}

// 注册
- (void)registWithUserName:(NSString *)userName
                 password:(NSString *)password
                 callBack:(BaseNetworkCallBack)callBack
{
    NSString *path = @"rest/ring/regist";
    NSDictionary *params = @{@"email" : userName,
                             @"password" :  password
                             };
    
    [self requestNetworkWithPath:path parameters:params callBackBlock:^(BOOL success, id responseObject, NSError *error) {
        if (success) {
            if (callBack) callBack(YES, responseObject, nil);
        } else {
            if (callBack) callBack(NO, responseObject, error);
        }
    }];
}

// 忘记密码
- (void)forgetPasswordWithEmail:(NSString *)email
                       callBack:(BaseNetworkCallBack)callBack
{
    NSString *path = @"rest/ring/forget-password";
    NSDictionary *params = @{@"email" : email};
    
    [self requestNetworkWithPath:path parameters:params callBackBlock:^(BOOL success, id responseObject, NSError *error) {
        if (success) {
            if (callBack) callBack(YES, responseObject, nil);
        } else {
            if (callBack) callBack(NO, responseObject, error);
        }
    }];
}

- (void)requestRankingListStartDate:(NSString *)startDate
                   endDate:(NSString *)endDate
                  callBack:(BaseNetworkCallBack)callBack
{
    NSString *path = @"rest/ring/get-rank-list-info";
    NSDictionary *params = @{@"id" : CurrentUser.userId?CurrentUser.userId:@"",
                             @"startDate" : startDate,
                             @"endDate" : endDate
                             };
    
    [self requestNetworkWithPath:path parameters:params callBackBlock:^(BOOL success, id responseObject, NSError *error) {
        if (success) {
            if (callBack) callBack(YES, responseObject, nil);
        } else {
            if (callBack) callBack(NO, responseObject, error);
        }
    }];
    
}

// 设置用户头像
- (void)setHeaderImage:(NSString *)headImage
              callBack:(BaseNetworkCallBack)callBack
{
    NSString *path = @"rest/ring/set-head-image";
    NSDictionary *params = @{@"id" : CurrentUser.userId,
                             @"headImage" :  headImage
                             };
    
    [self requestNetworkWithPath:path parameters:params callBackBlock:^(BOOL success, id responseObject, NSError *error) {
        if (success) {
            if (callBack) callBack(YES, responseObject, nil);
        } else {
            if (callBack) callBack(NO, responseObject, error);
        }
    }];
}

// 获取用户头像
- (void)getHeaderImage:(BaseNetworkCallBack)callBack
{
    NSString *path = @"rest/ring/get-head-image";
    NSDictionary *params = @{@"id" : CurrentUser.userId};
    
    [self requestNetworkWithPath:path parameters:params callBackBlock:^(BOOL success, id responseObject, NSError *error) {
        if (success) {
            if (callBack) callBack(YES, responseObject, nil);
        } else {
            if (callBack) callBack(NO, responseObject, error);
        }
    }];
}

// 编辑用户信息
- (void)editWithUserNickName:(NSString *)nickName
                     sex: (NSString *)sex
                    high: (NSString *)high
                  weight: (NSString *)weight
                     age: (NSString *)age
                stepLong: (NSString *)stepLong
                callBack:(BaseNetworkCallBack)callBack
{
    NSString *path = @"rest/ring/eidt-user-info";
    NSDictionary *params = @{@"id" : CurrentUser.userId,
                             @"nickName" : nickName,
                             @"sex" : sex,
                             @"high" : high,
                             @"weight" : weight,
                             @"age" : age,
                             @"stepLong" : stepLong,
                             };
    
    [self requestNetworkWithPath:path parameters:params callBackBlock:^(BOOL success, id responseObject, NSError *error) {
        if (success) {
            if (callBack) callBack(YES, responseObject, nil);
        } else {
            if (callBack) callBack(NO, responseObject, error);
        }
    }];
}

// 生产外设id
- (void)createExdeviceId:(BaseNetworkCallBack)callBack
{
    NSString *path = @"rest/ring/create-exdevice-id";
    
    [self requestNetworkWithPath:path parameters:nil callBackBlock:^(BOOL success, id responseObject, NSError *error) {
        if (success) {
            if (callBack) callBack(YES, responseObject, nil);
        } else {
            if (callBack) callBack(NO, responseObject, error);
        }
    }];
}


// 绑定设备
- (void)bindExdevice:(NSString *)exDeviceId
            callBack:(BaseNetworkCallBack)callBack
{
    NSString *path = @"rest/ring/bind-ex-device";
    NSDictionary *params = @{@"id" : CurrentUser.userId,
                             @"exDeviceId" :  exDeviceId
                             };
    
    [self requestNetworkWithPath:path parameters:params callBackBlock:^(BOOL success, id responseObject, NSError *error) {
        if (success) {
            if (callBack) callBack(YES, responseObject, nil);
        } else {
            if (callBack) callBack(NO, responseObject, error);
        }
    }];
}


// 保存步数
- (void)saveStepDataRecordDate:(NSString *)recordDate
             stepNum: (NSString *)stepNum
            callBack:(BaseNetworkCallBack)callBack
{
    NSString *path = @"rest/ring/save-step-data";
    NSDictionary *params = @{@"id" : CurrentUser.userId,
                             @"recordDate" :  recordDate,
                             @"stepNum" :  stepNum
                             };
    
    [self requestNetworkWithPath:path parameters:params callBackBlock:^(BOOL success, id responseObject, NSError *error) {
        if (success) {
            if (callBack) callBack(YES, responseObject, nil);
        } else {
            if (callBack) callBack(NO, responseObject, error);
        }
    }];
    
}


// 获取计步数据
- (void)getStepDataStartDate:(NSString *)startDate
            endDate: (NSString *)endDate
           callBack:(BaseNetworkCallBack)callBack
{
    NSString *path = @"rest/ring/get-step-data";
    NSDictionary *params = @{@"id" : CurrentUser.userId,
                             @"startDate" :  startDate,
                             @"endDate" :  endDate
                             };
    
    [self requestNetworkWithPath:path parameters:params callBackBlock:^(BOOL success, id responseObject, NSError *error) {
        if (success) {
            if (callBack) callBack(YES, responseObject, nil);
        } else {
            if (callBack) callBack(NO, responseObject, error);
        }
    }];
    
}


// 保存睡眠数据
- (void)saveSleepDataSleepDate:(NSString *)sleepDate
              qsmTime: (NSString *)qsmTime
              ssmTime: (NSString *)ssmTime
             callBack:(BaseNetworkCallBack)callBack
{
    NSString *path = @"rest/ring/save-sleep-data";
    NSDictionary *params = @{@"id" : CurrentUser.userId,
                             @"sleepDate" :  sleepDate,
                             @"qsmTime" :  qsmTime,
                             @"ssmTime" :  ssmTime
                             };
    
    [self requestNetworkWithPath:path parameters:params callBackBlock:^(BOOL success, id responseObject, NSError *error) {
        if (success) {
            if (callBack) callBack(YES, responseObject, nil);
        } else {
            if (callBack) callBack(NO, responseObject, error);
        }
    }];
}


// 获取睡眠数据
- (void)getSleepDataStartDate: (NSString *)startDate
             endDate: (NSString *)endDate
            callBack:(BaseNetworkCallBack)callBack
{
    NSString *path = @"rest/ring/get-sleep-data";
    NSDictionary *params = @{@"id" : CurrentUser.userId,
                             @"startDate" :  startDate,
                             @"endDate" :  endDate
                             };
    
    [self requestNetworkWithPath:path parameters:params callBackBlock:^(BOOL success, id responseObject, NSError *error) {
        if (success) {
            if (callBack) callBack(YES, responseObject, nil);
        } else {
            if (callBack) callBack(NO, responseObject, error);
        }
    }];
}

// 关联用户信息
- (void)relateUserInfoInviteCode: (NSString *)inviteCode
              callBack:(BaseNetworkCallBack)callBack
{
    NSString *path = @"rest/ring/relate-user-info";
    NSDictionary *params = @{@"id" : CurrentUser.userId,
                             @"inviteCode" :  inviteCode,
                             };
    
    [self requestNetworkWithPath:path parameters:params callBackBlock:^(BOOL success, id responseObject, NSError *error) {
        if (success) {
            if (callBack) callBack(YES, responseObject, nil);
        } else {
            if (callBack) callBack(NO, responseObject, error);
        }
    }];
}


@end
