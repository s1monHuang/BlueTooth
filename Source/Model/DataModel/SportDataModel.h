//
//  SportDataModel.h
//  BlueToothBracelet
//
//  Created by snhuang on 16/3/18.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SportDataModel : NSObject

@property(assign) NSInteger step;              //步数
@property(assign) NSInteger distance;          //距离
@property(assign) NSInteger calorie;           //卡路里
@property(assign) NSInteger target;            //目标
@property(assign) NSInteger battery;           //电量
@property(assign) NSInteger heatRate;           //心率

@end
