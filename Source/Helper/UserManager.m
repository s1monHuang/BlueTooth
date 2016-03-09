//
//  UserManager.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/5.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "UserManager.h"

@interface UserManager ()

@property (nonatomic, strong) UserEntity *currrentUser;

@end

@implementation UserManager

+ (instancetype)defaultInstance
{
    static UserManager *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[self alloc] init];
    });
    return _shareInstance;
}

+ (UserEntity *)currentUser{ // 当前用户
    
    return [UserManager defaultInstance].currrentUser;
}

- (UserEntity *)getUserFromLocalCache { // 获取本地用户
    NSDictionary *userDict = [[DataStoreHelper store] getObjectById:TBKeyUserInfo fromTable:TBNameUser];
    if (Dictionary(userDict)) {
        UserEntity *user = [[UserEntity alloc] initUserEntityWithDic:userDict];
        return user;
    }
    return nil;
}

- (void)saveUser:(NSDictionary *)userDict{ // 保存用户
    
    if (!userDict) return;
    self.currrentUser = [[UserEntity alloc] initUserEntityWithDic:userDict];
    
    if (userDict) {
        [[DataStoreHelper store] putObject:userDict withId:TBKeyUserInfo intoTable:TBNameUser];
    }
    
}

- (BOOL)hasUser {
    return self.currrentUser != nil;
}

- (void)clearUser {
    self.currrentUser = nil;
}

- (UserEntity *)currrentUser {
    if (!_currrentUser) {
        _currrentUser = [self getUserFromLocalCache];
    }
    return _currrentUser;
}

@end
