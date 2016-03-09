//
//  UtilityUI+ErrorImageView.h
//
//

#import "UtilityUI.h"

typedef void (^ViewTapHandler)(id userInfo);

@interface UtilityUI (ErrorImageView)

// 在baseView添加一个view用于显示居中一个图片和一段文字,支持点击重载事件
+ (void)showErrorImageView:(UIView *)baseView
                      text:(NSString *)text;

+ (void)showErrorImageView:(UIView *)baseView
                     image:(UIImage *)image;

+ (void)showErrorImageView:(UIView *)baseView
                     image:(UIImage *)image
                      text:(NSString *)text;

+ (void)showErrorImageView:(UIView *)baseView
                     image:(UIImage *)image
                      text:(NSString *)text
            viewTapHandler:(ViewTapHandler)viewTapHandler;

+ (void)showErrorImageView:(UIView *)baseView
                     image:(UIImage *)image
                      text:(NSString *)text
               showedAtTop:(BOOL)showedAtTop
            viewTapHandler:(ViewTapHandler)viewTapHandler;

+ (void)showErrorImageView:(UIView *)baseView
                     image:(UIImage *)image
                      text:(NSString *)text
                  textFont:(UIFont *)textFont
                 textColor:(UIColor *)textColor
           backgroundColor:(UIColor *)backgroudColor
                 edgeInset:(UIEdgeInsets)edgeInset
               showedAtTop:(BOOL)showedAtTop
            viewTapHandler:(ViewTapHandler)viewTapHandler;

+ (void)hideErrorImageView:(UIView *)baseView;

@end
