//
//  UtilityUI+ProgressHUD.h
//

#import "UtilityUI.h"

@interface UtilityUI (ProgressHUD)

// 菊花加文字，可以enabledUserInteraction是否锁定当前View的操作
+ (void)showHUDLoading:(UIView *)baseView;
+ (void)showHUDLoading:(UIView *)baseView enabledUserInteraction:(BOOL)enabledUserInteraction;
+ (void)showHUDLoading:(UIView *)baseView text:(NSString *)text;
+ (void)showHUDLoading:(UIView *)baseView text:(NSString *)text enabledUserInteraction:(BOOL)enabledUserInteraction;

// 提示性文字，默认显示再window上
+ (void)showHUDText:(NSString *)text;
+ (void)showHUDText:(NSString *)text duration:(NSTimeInterval)duration;
+ (void)showHUDText:(NSString *)text image:(UIImage *)image;
+ (void)showHUDText:(NSString *)text image:(UIImage *)image duration:(NSTimeInterval)duration;
+ (void)showHUDText:(NSString *)text image:(UIImage *)image duration:(NSTimeInterval)duration inView:(UIView *)baseView;
+ (void)showHUDWithSuccessText:(NSString *)text;
+ (void)showHUDWithErrorText:(NSString *)text;

// 隐藏
+ (void)hideHUDView:(UIView *)baseView;   // 针对菊花
+ (void)hideHUDView; // 针对提示性文字

// 显示系统菊花，居中现实
+ (void)showSystemLoadingInView:(UIView *)inView;
+ (void)hideSystemLoadingInView:(UIView *)inView;

@end
