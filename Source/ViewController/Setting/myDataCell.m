//
//  myDataCell.m
//  BlueToothBracelet
//
//  Created by azz on 16/3/15.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "myDataCell.h"

@interface myDataCell()

@end

@implementation myDataCell

- (instancetype)init
{
    if (self = [super init]) {
        _keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 50, self.height)];
        [self addSubview:_keyLabel];
        
        CGFloat valueLabelX = CGRectGetMaxX(_keyLabel.frame);
        CGFloat valueLabelW = kScreenWidth - valueLabelX - 30;
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(valueLabelX, 0, valueLabelW, self.height)];
        _valueLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_valueLabel];
    }
    return self;
}

@end
