//
//  HistroySportDataModel.h
//  BlueToothBracelet
//
//  Created by snhuang on 16/3/21.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistorySportDataModel : NSObject

@property(assign) NSInteger time;              //前几个小时的数据
@property(assign) NSInteger step;              //步数
@property(assign) NSInteger calorie;           //卡路里
@property(assign) NSInteger sleep;             //睡眠动作次数
@property(assign) NSInteger battery;           //电量

@property(nonatomic,strong) NSDate *date;      //具体日期

@end
