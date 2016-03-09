//
//  UserManager.h
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/5.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataStoreHelper.h"
#import "UserEntity.h"

#define CurrentUser       [UserManager currentUser]

@interface UserManager : NSObject

+ (instancetype)defaultInstance;

+ (UserEntity *)currentUser; // 当前用户

- (void)saveUser:(UserEntity *)user; // 保存用户

- (BOOL)hasUser; // 是否有用户，登录时候用

- (void)clearUser; // 清除用户

@end
