//
//  UtilityUI.m
//

#import "UtilityUI.h"
#import "UINavigationBar+FlatUI.h"

@implementation UtilityUI

+ (void)setBorderOnView:(UIView *)view borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius {
    if (!view) {
        return;
    }
    
    borderColor = borderColor ? borderColor : [UIColor redColor];
    borderWidth = borderWidth >= 0 ? borderWidth : kUtilityUIDefaultBorderWidth;
    cornerRadius = cornerRadius >= 0 ? cornerRadius : kUtilityUIDefaultBorderCornerRadius;
    
    view.layer.borderColor = borderColor.CGColor;
    view.layer.borderWidth = borderWidth;
    view.layer.cornerRadius = cornerRadius;
    if (cornerRadius >= 0) {
        view.clipsToBounds = YES;
    }
}

+ (void)setBorderOnView:(UIView *)view {
    [self setBorderOnView:view borderColor:view.backgroundColor borderWidth:kUtilityUIDefaultBorderWidth cornerRadius:kUtilityUIDefaultBorderCornerRadius];
}

+ (void)setBorderOnView:(UIView *)view cornerRadius:(CGFloat)cornerRadius {
    [self setBorderOnView:view borderColor:view.backgroundColor borderWidth:0.0f cornerRadius:cornerRadius];
}

+ (void)setBorderOnView:(UIView *)view borderColor:(UIColor *)borderColor{
    [self setBorderOnView:view borderColor:borderColor borderWidth:kUtilityUIDefaultBorderWidth cornerRadius:kUtilityUIDefaultBorderCornerRadius];
}

+ (void)setNavigationStyle:(UINavigationBar*)bar{
    [bar configureFlatNavigationBarWithColor:[UtilityUI stringTOColor:@"#06bd90"]];
    bar.barStyle = UIBarStyleBlackOpaque;
    //bar.barTintColor = [UtilityUI stringTOColor:@"#06bd90"];
    bar.translucent = NO;
    bar.tintColor=[UIColor whiteColor];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[UIColor whiteColor],[UIFont boldSystemFontOfSize:20.0f], nil] forKeys:[NSArray arrayWithObjects:NSForegroundColorAttributeName,NSFontAttributeName, nil]];
    bar.titleTextAttributes = dict;
}

+ (void)setTabBarStyle:(UITabBarItem*)tabBar
{
    //设置 tabbar 上面的字体大小 和颜色
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[UIColor colorWithRed:121/255.0 green:129/255.0 blue:145/255.0 alpha:1.0],[UIFont systemFontOfSize:14.0f], nil] forKeys:[NSArray arrayWithObjects:NSForegroundColorAttributeName,NSFontAttributeName, nil]];
    
    NSDictionary *dicted = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[UIColor colorWithRed:50/255.0 green:202/255.0 blue:164/255.0 alpha:1.0],[UIFont boldSystemFontOfSize:13.0f], nil] forKeys:[NSArray arrayWithObjects:NSForegroundColorAttributeName,NSFontAttributeName, nil]];
    
    [tabBar setTitleTextAttributes:dict forState:UIControlStateNormal];
    [tabBar setTitleTextAttributes:dicted forState:UIControlStateSelected];
    
}

+ (UIColor *) stringTOColor:(NSString *)str
{
    if (!str || [str isEqualToString:@""]) {
        return nil;
    }
    unsigned red,green,blue;
    NSRange range;
    range.length = 2;
    range.location = 1;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&red];
    range.location = 3;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&green];
    range.location = 5;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&blue];
    UIColor *color= [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1];
    return color;
}

@end
