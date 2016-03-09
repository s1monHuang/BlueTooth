//
//  UtilityUI+ProgressHUD.m
//

#import "UtilityUI+ProgressHUD.h"
#import "MBProgressHUD.h"

static NSInteger const HUDDefaultShowTime = 1.0f;
static NSInteger const HUDLongShowTime = 1.8f;

// 分类型，暂时没用上
typedef NS_ENUM(NSInteger, HUDMaskType) {
    HUDMaskTypeNone = 1,
    HUDMaskTypeClear,
    HUDMaskTypeBlack,
    HUDMaskTypeGradient,
    HUDMaskTypeFullScreen
};

typedef NS_ENUM(NSInteger, HUDPosition) {
    HUDPositionCentre,
    HUDPositionTop
};

@implementation UtilityUI (ProgressHUD)

+ (void)showHUDLoading:(UIView *)baseView {
    [self showHUDLoading:baseView enabledUserInteraction:YES];
}

+ (void)showHUDLoading:(UIView *)baseView enabledUserInteraction:(BOOL)enabledUserInteraction {
    [self showHUDLoading:baseView text:nil enabledUserInteraction:enabledUserInteraction];
}

+ (void)showHUDLoading:(UIView *)baseView text:(NSString *)text {
    [self showHUDLoading:baseView text:text enabledUserInteraction:YES];
}

+ (void)showHUDLoading:(UIView *)baseView text:(NSString *)text enabledUserInteraction:(BOOL)enabledUserInteraction {
    [self showHUDLoading:YES text:text image:nil duration:0 position:HUDPositionCentre baseView:baseView maskType:enabledUserInteraction ? HUDMaskTypeClear : HUDMaskTypeFullScreen];
}

+ (void)showHUDText:(NSString *)text {
    [self showHUDText:text image:nil];
}

+ (void)showHUDText:(NSString *)text duration:(NSTimeInterval)duration{
    [self showHUDText:text image:nil duration:duration];
}

+ (void)showHUDWithSuccessText:(NSString *)text {
    UIImage *successImage = [UIImage imageNamed:@"37x-Checkmark"];
    [self showHUDText:text image:successImage];
}

+ (void)showHUDWithErrorText:(NSString *)text {
    UIImage *failureImage = [UIImage imageNamed:@"37x-Checkmark_temp"];
    [self showHUDText:text image:failureImage];
}

+ (void)showHUDText:(NSString *)text image:(UIImage *)image {
    [self showHUDText:text image:image duration:0];
}

+ (void)showHUDText:(NSString *)text image:(UIImage *)image duration:(NSTimeInterval)duration {
    [self showHUDText:text image:image duration:duration inView:nil];
}

+ (void)showHUDText:(NSString *)text image:(UIImage *)image duration:(NSTimeInterval)duration inView:(UIView *)baseView {
    CGFloat mDuration = duration;
    if (mDuration <= 0) {
        mDuration = (text && text.length > 12) ? HUDLongShowTime : HUDDefaultShowTime;
    }
    
    [self showHUDLoading:NO text:text image:image duration:mDuration position:HUDPositionCentre baseView:baseView maskType:HUDMaskTypeClear];
}

+ (void)showHUDLoading:(BOOL)loading
                  text:(NSString *)text
                 image:(UIImage *)image
              duration:(NSTimeInterval)duration
              position:(HUDPosition)position
              baseView:(UIView *)baseView
              maskType:(HUDMaskType)maskType
{
    if (loading == NO && (!text || text.length == 0)) {
        return;
    }
    
    if (loading && !baseView) {
        return;
    }

    UIView *fatherView = loading ? baseView : [self getCurrentShowWindow];
    
    CGFloat offet = 0.0f;
    if (position == HUDPositionTop) offet = -150.f;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:fatherView animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.detailsLabelText = text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16.0f];
    hud.yOffset = offet;
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNFProgressHUDDidShow object:fatherView];
    
    if (loading) {
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.backgroundColor = RGBA(0.0f, 0.0f, 0.0f, 0.25f);
    } else {
        NSTimeInterval mDuration = duration > 0 ? duration: HUDDefaultShowTime;
        if (image) {
            hud.mode = MBProgressHUDModeCustomView;
            hud.customView = [[UIImageView alloc] initWithImage:image];
        } else {
            hud.cornerRadius = 5.0f;
            hud.mode = MBProgressHUDModeText;
        }
        hud.margin = 8.0f;
        [hud hide:YES afterDelay:mDuration];
    }
}

+ (void)hideHUDView:(UIView *)baseView {
    UIView *mFatherView = baseView ?: [self getCurrentShowWindow];
    for (UIView *subVIew in mFatherView.subviews) {
        if ([subVIew isKindOfClass:[MBProgressHUD class]]) {
            [((MBProgressHUD *)subVIew) hide:YES];
        }
    }
}

+ (void)hideHUDView {
    [self hideHUDView:[self getCurrentShowWindow]];
}

#pragma mark -

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

#pragma mark -
+ (void)showSystemLoadingInView:(UIView *)inView
{
    if (!inView) return;
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.frame = CGRectMake(0, 0, 20.0f, 20.0f);
    activityIndicatorView.center = CGPointMake(inView.bounds.size.width / 2, inView.bounds.size.height / 2);
    activityIndicatorView.tag = 21221;
    [activityIndicatorView startAnimating];
    
    [inView addSubview:activityIndicatorView];
    [inView bringSubviewToFront:activityIndicatorView];
}

+ (void)hideSystemLoadingInView:(UIView *)inView
{
    if (!inView) return;
    UIView *view = [inView viewWithTag:21221];
    if (view) {
        [view removeFromSuperview];
    }
}

@end
