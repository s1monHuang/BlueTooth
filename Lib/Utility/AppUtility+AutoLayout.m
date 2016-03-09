//
//  AppUtility+AutoLayout.m
//  MobileDoctor
//
//  Created by Ddread Li on 5/26/15.
//  Copyright (c) 2015 DCS Technology. All rights reserved.
//

#import "AppUtility+AutoLayout.h"

@implementation AppUtility (AutoLayout)

+ (void)makeZeroEdgeInsetConstraintOnView:(UIView *)view superView:(UIView *)superView {
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    [[self class] makeEdgeInsetConstraintOnView:view superView:superView paddingInsets:padding];
}

+ (void)makeEdgeInsetConstraintOnView:(UIView *)view superView:(UIView *)superView paddingInsets:(UIEdgeInsets)padding {
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView).with.insets(padding);
    }];

}


@end
