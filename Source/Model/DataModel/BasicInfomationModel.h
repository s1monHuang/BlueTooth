//
//  BasicInfomationModel.h
//  BlueToothBracelet
//
//  Created by snhuang on 16/3/23.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BasicInfomationModel : NSObject

@property (nonatomic,assign) NSInteger height;              //身高
@property (nonatomic,assign) NSInteger weight;              //体重
@property (nonatomic,assign) NSInteger distance;            //步距
@property (nonatomic,assign) NSInteger clockSwith;          //闹钟开关
@property (nonatomic,assign) NSInteger clockHour;           //时(闹钟)
@property (nonatomic,assign) NSInteger clockMinute;         //分(闹钟)
@property (nonatomic,assign) NSInteger clockInterval;       //提醒间隔(闹钟)

@property (nonatomic,assign) NSInteger sportSwith;          //运动提醒开关
@property (nonatomic,assign) NSInteger startTime;           //开始时间(运动提醒)
@property (nonatomic,assign) NSInteger endTime;             //结束时间(运动提醒)
@property (nonatomic,assign) NSInteger sportInterval;       //提醒间隔(运动提醒)

@property (nonatomic,assign) NSInteger target;              //每天的运动目标

@end
