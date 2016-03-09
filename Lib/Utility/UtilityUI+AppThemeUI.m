//
//  UtilityUI+AppThemeUI.m
//
//

#import "UtilityUI+AppThemeUI.h"

@implementation UtilityUI (AppThemeUI)

#pragma mark - UIButton

+ (void)setThemeButton:(UIButton *)button {
    if (!button) return;
    
    button.backgroundColor = nil;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    button.backgroundColor = kThemeColor;
    [UtilityUI setBorderOnView:button];
}

+ (UIButton *)getThemeButton {
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 20.0f * 2;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, 44.0f)];
    [self setThemeButton:button];
    return button;
}

+ (void)setThemeTextField:(UITextField *)textField {
    if (!textField) return;
    [UtilityUI setBorderOnView:textField borderColor:kThemeGrayColor];
}

+ (UITextField *)getThemeTextField {
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 20.0f * 2;
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, width, 44.0f)];
    [self setThemeTextField:textField];
    return textField;
}

#pragma mark - UIImage

+ (UIImage *)defaultErrorImage {
    return [UIImage imageNamed:@"BB_cry"];
}

@end
