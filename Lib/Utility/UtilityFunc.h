//
//  UtilityFunc.h
//
//

#import <Foundation/Foundation.h>

@interface UtilityFunc : NSObject

// 从xib上获取View
+ (UIView *)viewOnNibWithTag:(NSInteger)tag nibName:(NSString*)nibNime;

// 获取当前显示的window
+ (UIWindow *)getCurrentShowWindow;

+ (UIImage *)compressImage:(UIImage *)image;

@end
