//
//  UtilityUI.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define  kUtilityUIDefaultBorderWidth                    1.0f
#define  kUtilityUIDefaultBorderCornerRadius             4.0f

@interface UtilityUI : NSObject

// 代码设置设置边界和圆角，默认是view的背景色,1.0f borderWidth,5.0f cornerRadius
+ (void)setBorderOnView:(UIView *)view;
+ (void)setBorderOnView:(UIView *)view borderColor:(UIColor *)borderColor;
+ (void)setBorderOnView:(UIView *)view cornerRadius:(CGFloat)cornerRadius;
+ (void)setBorderOnView:(UIView *)view borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius;

//设置导航样式
+ (void)setNavigationStyle:(UINavigationBar*)bar;
// 设置Tabbar样式
+ (void)setTabBarStyle:(UITabBarItem*)tabBar;

// 16进制颜色
+ (UIColor *) stringTOColor:(NSString *)str;

@end
