//
//  AppUtility+AutoLayout.h
//  MobileDoctor
//
//  Created by Ddread Li on 5/26/15.
//  Copyright (c) 2015 DCS Technology. All rights reserved.
//

#import "AppUtility.h"

@interface AppUtility (AutoLayout)

+ (void)makeZeroEdgeInsetConstraintOnView:(UIView *)view superView:(UIView *)superView;
+ (void)makeEdgeInsetConstraintOnView:(UIView *)view superView:(UIView *)superView paddingInsets:(UIEdgeInsets)padding;

@end
