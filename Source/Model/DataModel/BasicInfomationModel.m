//
//  BasicInfomationModel.m
//  BlueToothBracelet
//
//  Created by snhuang on 16/3/23.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "BasicInfomationModel.h"

@implementation BasicInfomationModel

- (instancetype)init
{
    if (self = [super init]) {
        _target = 0;
        _sportInterval = 0;
        _startTime = 0;
        _endTime = 0;
        _sportSwitch = 0;
        _clockHour = 0;
        _clockSwitch = 0;
        _clockMinute = 0;
        _clockInterval = 0;
    }
    return self;
}

@end
