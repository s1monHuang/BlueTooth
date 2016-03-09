//
//  UIViewController-ProgressHUD.m
//  DGroupDoctor
//
//  Created by Ddread Li on 6/23/15.
//  Copyright (c) 2015 Dachen Tech. All rights reserved.
//

#import "UIViewController+ProgressHUD.h"
#import "UtilityUI+ProgressHUD.h"

@implementation UIViewController (ProgressHUD)

- (void)showHUDLoading
{
    [UtilityUI showHUDLoading:self.view text:nil enabledUserInteraction:YES];
}

- (void)showHUDLoadingEnabledUserInteraction:(BOOL)enabledUserInteraction
{
    [UtilityUI showHUDLoading:self.view text:nil enabledUserInteraction:enabledUserInteraction];
}

- (void)showHUDLoadingText:(NSString *)text
{
    [UtilityUI showHUDLoading:self.view text:text enabledUserInteraction:YES];
}

- (void)showHUDLoadingText:(NSString *)text enabledUserInteraction:(BOOL)enabledUserInteraction
{
    [UtilityUI showHUDLoading:self.view text:nil enabledUserInteraction:enabledUserInteraction];

}

- (void)showHUDText:(NSString *)text
{
    [UtilityUI showHUDText:text image:nil duration:0 inView:self.view];
}

- (void)showHUDText:(NSString *)text duration:(NSTimeInterval)duration
{
    [UtilityUI showHUDText:text image:nil duration:duration inView:self.view];
}

- (void)showHUDText:(NSString *)text image:(UIImage *)image
{
    [UtilityUI showHUDText:text image:image duration:0 inView:self.view];
}

- (void)showHUDText:(NSString *)text image:(UIImage *)image duration:(NSTimeInterval)duration
{
    [UtilityUI showHUDText:text image:image duration:duration inView:self.view];
}

- (void)showHUDWithSuccessText:(NSString *)text
{
    [UtilityUI showHUDWithSuccessText:text];
}

- (void)showHUDWithErrorText:(NSString *)text
{
    [UtilityUI showHUDWithErrorText:text];
}

- (void)hideHUDView
{
    [UtilityUI hideHUDView:self.view];
}

@end
