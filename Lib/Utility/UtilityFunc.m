//
//  UtilityFunc.m
//
//

#import "UtilityFunc.h"

@implementation UtilityFunc

+ (UIView *)viewOnNibWithTag:(NSInteger)tag nibName:(NSString*)nibNime
{
    UIView *view = nil;
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:nibNime ?: @"ViewDesigner" owner:nil options:nil];
    for(UIView *v in array) {
        if([v isKindOfClass:[UIView class]] && v.tag == tag) {
            view = v;
            break;
        }
    }
    return view;
}

+ (UIWindow *)getCurrentShowWindow {
    UIWindow *currentShowWindow = nil;
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows){
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
        
        if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
            currentShowWindow = window;
            break;
        }
    }
    return currentShowWindow;
}

// 压缩成默认图片，长宽不超过960*960，压缩质量0.45，大小100k左右
+ (UIImage *)compressImage:(UIImage *)image {
    return [[self class] compressImage:image compressionQuality:0.45f maxWidth:960.0f maxHeight:960.0f];
}

// 压缩图片
+ (UIImage *)compressImage:(UIImage *)image
        compressionQuality:(CGFloat)compressionQuality
                  maxWidth:(CGFloat)maxWidth
                 maxHeight:(CGFloat)maxHeight
{
    if (!image) return nil;
    
    CGSize scaleSize=((UIImage *)image).size;
    if (maxHeight > 0 && maxWidth > 0) {
        scaleSize = [self getImageAspectSize:image.size maxWidth:maxWidth maxHeight:maxHeight minLenght:0.0f];
    }
    UIImage *thumbnailImage =[self scaleImage:image scaleToSize:scaleSize];
    CGFloat eCompressionQuality = compressionQuality > 0 ? compressionQuality : 1.0f;
    eCompressionQuality = compressionQuality < 1.0f ? compressionQuality : 1.0f;
    NSData *imageData = UIImageJPEGRepresentation(thumbnailImage, eCompressionQuality);
    
    return [UIImage imageWithData:imageData];
}

+ (CGSize)getImageAspectSize:(CGSize)originalSize maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight minLenght:(CGFloat)minLenght {
    
    if (originalSize.width == 0 || originalSize.height == 0) return CGSizeMake(0, 0);
    if (maxHeight == 0 || maxWidth == 0) return CGSizeMake(maxWidth, maxHeight);
    if (minLenght <= 0.0f) minLenght = 50.0f;
    
    CGFloat retWidth = 0.0f;
    CGFloat retHeight = 0.0f;
    
    // 以原始size的最小边为准
    if (maxWidth >= originalSize.width && maxHeight >= originalSize.height) {
        return originalSize;
    }
    
    // 先压缩最大边，如果最小边小于最小值则以最小值为准
    if (originalSize.height > originalSize.width) {
        retHeight = maxHeight;
        retWidth = retHeight * originalSize.width / originalSize.height;
        if (retWidth < minLenght) { // 如果小于最小长度，则以最小长度为准
            retWidth = minLenght;
            retHeight = retWidth * originalSize.height / originalSize.width;
        }
    } else if (originalSize.height < originalSize.width) {
        retWidth = maxWidth;
        retHeight = retWidth * originalSize.height / originalSize.width;
        if (retHeight < minLenght) {
            retHeight = minLenght;
            retWidth = retHeight * originalSize.width / originalSize.height;
        }
    } else if (originalSize.height == originalSize.width){
        retWidth = MIN(maxWidth, maxHeight);
        retHeight = retWidth;
    }
    
    return CGSizeMake(retWidth, retHeight);
}

+ (UIImage *)scaleImage:(UIImage *)image scaleToSize:(CGSize)newSize
{
    if (!image) return nil;
    if (newSize.width == 0 || newSize.height == 0) return image;
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *changeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return changeImage;
}

@end
