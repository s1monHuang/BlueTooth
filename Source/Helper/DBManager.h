//
//  DBManager.h
//  BlueToothBracelet
//
//  Created by snhuang on 16/3/18.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "SportDataModel.h"
#import "BasicInfomationModel.h"
#import "HistroySportDataModel.h"


@interface DBManager : NSObject

+ (BOOL)initApplicationsDB;

#pragma mark - BasicData

/*!
 *  保存或替换基本信息
 *
 *  @param model BasicInfomationModel
 *
 *  @return
 */
+ (BOOL)insertOrReplaceBasicInfomation:(BasicInfomationModel *)model;

/*!
 *  获取当前用户的基本信息
 *
 *  @return BasicInfomationModel
 */
+ (BasicInfomationModel *)selectBasicInfomation;

#pragma mark - SportData
/*!
 *  保存或替换运动数据
 *
 *  @param model SportDataModel
 *
 *  @return
 */
+ (BOOL)insertOrReplaceSportData:(SportDataModel *)model;

/*!
 *  保存或替换运动数据
 *
 *  @param model SportDataModel
 *  @param db    FMDatabase
 *
 *  @return
 */
+ (BOOL)insertOrReplaceSportData:(SportDataModel *)model
                        database:(FMDatabase *)db;

/*!
 *  获取当前用户的运动数据
 *
 *  @return SportDataModel
 */
+ (SportDataModel *)selectSportData;

/*!
 *  保存或替换历史运动数据
 *
 *  @param model HistroySportDataModel
 *
 *  @return
 */
+ (BOOL)insertOrReplaceHistroySportData:(HistroySportDataModel *)model;


/*!
 *  保存或替换历史运动数据
 *
 *  @param model HistroySportDataModel
 *  @param db    FMDatabase
 *
 *  @return
 */
+ (BOOL)insertOrReplaceHistroySportData:(HistroySportDataModel *)model
                               database:(FMDatabase *)db;


/*!
 *  获取当前用户前N个小时的数据
 *
 *  @param time 当前时间前几个小时
 *
 *  @return HistroySportDataModel
 */
+ (HistroySportDataModel *)selectHistroySportDataByTime:(NSInteger)time;

@end
