//
//  UIViewController+ProgressHUD.h
//  DGroupDoctor
//
//  Created by Ddread Li on 6/23/15.
//  Copyright (c) 2015 Dachen Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ProgressHUD)

// 菊花加文字，可以enabledUserInteraction是否锁定当前View的操作
- (void)showHUDLoading;
- (void)showHUDLoadingEnabledUserInteraction:(BOOL)enabledUserInteraction;
- (void)showHUDLoadingText:(NSString *)text;
- (void)showHUDLoadingText:(NSString *)text enabledUserInteraction:(BOOL)enabledUserInteraction;

// 提示性文字，默认显示再window上
- (void)showHUDText:(NSString *)text;
- (void)showHUDText:(NSString *)text duration:(NSTimeInterval)duration;
- (void)showHUDText:(NSString *)text image:(UIImage *)image;
- (void)showHUDText:(NSString *)text image:(UIImage *)image duration:(NSTimeInterval)duration;
- (void)showHUDWithSuccessText:(NSString *)text;
- (void)showHUDWithErrorText:(NSString *)text;

// 隐藏
- (void)hideHUDView; // 针对提示性文字

@end
