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
#import "HistroySportDataModel.h"

@interface DBManager : NSObject

+ (BOOL)initApplicationsDB;

+ (BOOL)insertOrReplaceSportData:(SportDataModel *)model;

+ (BOOL)insertOrReplaceSportData:(SportDataModel *)model
                        database:(FMDatabase *)db;

+ (SportDataModel *)selectSportDataBydatabase:(FMDatabase *)db;

+ (BOOL)insertOrReplaceHistroySportData:(HistroySportDataModel *)model;

+ (BOOL)insertOrReplaceHistroySportData:(HistroySportDataModel *)model
                               database:(FMDatabase *)db;

+ (HistroySportDataModel *)selectHistroySportDataByTime:(NSInteger)time
                                               database:(FMDatabase *)db;

@end
