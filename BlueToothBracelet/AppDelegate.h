//
//  AppDelegate.h
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/2.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DOWNLOADSUCCESS  @"DOWNLOADSUCCESS"    //持续登录

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UITabBarController *mainTabBarController;

@property (nonatomic , copy) NSString *userName;

@property (nonatomic , copy) NSString *password;

// 当前类的一个单例方法
+ (AppDelegate *)defaultDelegate;


- (void)exchangeRootViewControllerToLogin;
- (void)exchangeRootViewControllerToMain;

/*
 
 1 运动右上角的按钮是跳到哪里？
 2 排名右上角的按钮是跳到哪里？
 3 找回密码没有UI
 4 个人->我的资料 ->  设置年龄,身高,体重的顺序是咋样的
 5 个人->训练目标 ->  没有UI
 6 个人->提醒设置 ->  没有UI
 7 个人->智能闹钟 ->  没有UI
 8 个人->关于我们 ->  没有UI
 
 目前发现的就这些
 
 */

@end

