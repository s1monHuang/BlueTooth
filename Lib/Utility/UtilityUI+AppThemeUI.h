//
//  UtilityUI+AppThemeUI.h
//
//

#import "UtilityUI.h"

@interface UtilityUI (AppThemeUI)

#pragma mark - UIButton

// 主题UIButton
+ (void)setThemeButton:(UIButton *)button;
+ (UIButton *)getThemeButton;

// 主题UITextField
+ (void)setThemeTextField:(UITextField *)textField;
+ (UITextField *)getThemeTextField;


#pragma mark - UIImage

// 获取默认错误或空图片
+ (UIImage *)defaultErrorImage;

@end
