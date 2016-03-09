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

- (void)requestRankingList:(NSString *)dateType
                  callBack:(BaseNetworkCallBack)callBack;
{
    NSString *path = @"rest/ring/get-rank-list-info";
    NSDictionary *params = @{@"id" : CurrentUser.userId,
                             @"dateType" : dateType
                             };
    
    [self requestNetworkWithPath:path parameters:params callBackBlock:^(BOOL success, id responseObject, NSError *error) {
        if (success) {
            if (callBack) callBack(YES, responseObject[@"data"], nil);
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

@end
