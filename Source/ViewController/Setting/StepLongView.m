//
//  StepLongView.m
//  BlueToothBracelet
//
//  Created by azz on 16/3/21.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "StepLongView.h"

@implementation StepLongView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(self.width, 0)];
    [path moveToPoint:CGPointMake(self.width * 0.5 , 0)];
    [path addLineToPoint:CGPointMake(self.width * 0.5, self.height)];
    [path moveToPoint:CGPointMake(0 ,  self.height)];
    [path addLineToPoint:CGPointMake(self.width, self.height)];
    
    UIColor *color = KThemeGreenColor;
    [color set];
    [path stroke];
    path.lineWidth = 0.8;
}


@end
