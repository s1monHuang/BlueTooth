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

// 忘记密码
- (void)forgetPasswordWithEmail:(NSString *)email
                       callBack:(BaseNetworkCallBack)callBack;

// 获取排名数据
- (void)requestRankingList:(NSString *)dateType
                  callBack:(BaseNetworkCallBack)callBack;

// 设置用户头像
- (void)setHeaderImage:(NSString *)headImage
              callBack:(BaseNetworkCallBack)callBack;

// 获取用户头像
- (void)getHeaderImage:(BaseNetworkCallBack)callBack;



@end
