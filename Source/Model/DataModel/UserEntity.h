//
//  UserEntity.h
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/5.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserEntity : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSString *high;
@property (nonatomic, strong) NSString *ex_deviceId;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) NSString *stepLong;
@property (nonatomic, strong) NSString *weight;
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *age;
@property (nonatomic, strong) NSString *token;

@property (nonatomic , copy) NSString *inviteCode;    //邀请码

- (instancetype)initUserEntityWithDic:(NSDictionary *)dict;

@end
