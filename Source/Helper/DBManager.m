//
//  DBManager.m
//  BlueToothBracelet
//
//  Created by snhuang on 16/3/18.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "DBManager.h"
#import "SportDataModel.h"
#import "HistroySportDataModel.h"
#import "BasicInfomationModel.h"
#import "UserManager.h"

#define DB_FILENAME @"bluetooth.sqlite"

static FMDatabaseQueue *dbQueue = nil;
static NSString *dbPath = nil;

@implementation DBManager

+ (FMDatabaseQueue *)dbQueue {
    return dbQueue;
}


/*!
 *  创建相关DB
 *
 *  @return 成功或者失败
 */
+ (BOOL)initApplicationsDB {
    
    if (dbPath) {
        dbPath = nil;
    }
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath = [documentsPath stringByAppendingPathComponent:DB_FILENAME];
    NSLog(@"dbPath: %@", dbPath);
    
    if (dbQueue) {
        [dbQueue close];
        dbQueue = nil;
    }
    dbQueue = [[FMDatabaseQueue alloc] initWithPath:dbPath];
    
    __block BOOL success = NO;
    [dbQueue inDatabase:^(FMDatabase *db) {
        if (![DBManager createBasicInfomationTable:db]) {
            NSLog(@"createBasicInfomationTable error");
            return;
        }
        if (![DBManager createSportDataTable:db]) {
            NSLog(@"createSportDataTable error");
            return;
        }
        if (![DBManager createHistroySportDataTable:db]) {
            NSLog(@"createHistroySportDataTable error");
            return;
        }
        success = YES;
    }];
    return success;
    
}

//@property (nonatomic,assign) NSInteger height;              //身高
//@property (nonatomic,assign) NSInteger weight;              //体重
//@property (nonatomic,assign) NSInteger distance;            //步距
//@property (nonatomic,assign) NSInteger clockSwith;          //闹钟开关
//@property (nonatomic,assign) NSInteger clockHour;           //时(闹钟)
//@property (nonatomic,assign) NSInteger clockMinute;         //分(闹钟)
//@property (nonatomic,assign) NSInteger clockInterval;       //提醒间隔(闹钟)
//
//@property (nonatomic,assign) NSInteger sportSwith;          //运动提醒开关
//@property (nonatomic,assign) NSInteger startTime;           //开始时间(运动提醒)
//@property (nonatomic,assign) NSInteger endTime;             //结束时间(运动提醒)
//@property (nonatomic,assign) NSInteger sportInterval;       //提醒间隔(运动提醒)
//
//@property (nonatomic,assign) NSInteger target;              //每天的运动目标

+ (BOOL)createBasicInfomationTable:(FMDatabase *)db {
    NSString *createAppsSql = @"CREATE TABLE IF NOT EXISTS 'basic_infomation_table' (\
    'user_id' TEXT PRIMARY KEY NOT NULL ,\
    'nick_name' TEXT,\
    'gender' TEXT,\
    'age' TEXT,\
    'height' INTEGER,\
    'weight' INTEGER,\
    'distance' INTEGER,\
    'clockSwith' INTEGER,\
    'clockHour' INTEGER,\
    'clockMinute' INTEGER,\
    'clockInterval' INTEGER,\
    'sportSwith' INTEGER,\
    'startTime' INTEGER,\
    'endTime' INTEGER,\
    'sportInterval' INTEGER,\
    'target' INTEGER)";
    return [db executeUpdate:createAppsSql];
}

+ (BOOL)createSportDataTable:(FMDatabase *)db {
    NSString *createAppsSql = @"CREATE TABLE IF NOT EXISTS 'sport_table' (\
    'user_id' TEXT PRIMARY KEY NOT NULL ,\
    'step' INTEGER,\
    'distance' INTEGER,\
    'calorie' INTEGER,\
    'target' INTEGER,\
    'battery' INTEGER)";
    return [db executeUpdate:createAppsSql];
}

+ (BOOL)createHistroySportDataTable:(FMDatabase *)db {
    NSString *createAppsSql = @"CREATE TABLE IF NOT EXISTS 'histroy_sport_table' (\
    'user_id' TEXT NOT NULL ,\
    'time' INTEGER,\
    'calorie' INTEGER,\
    'sleep' INTEGER,\
    'battery' INTEGER,\
    'date' DATE,\
    PRIMARY KEY ('user_id' , 'time'))";
    return [db executeUpdate:createAppsSql];
}

+ (BOOL)insertOrReplaceBasicInfomation:(BasicInfomationModel *)model {
    __block BOOL success = NO;
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO 'basic_infomation_table' (\
                         'user_id',\
                         'nick_name',\
                         'gender',\
                         'age',\
                         'height',\
                         'weight',\
                         'distance',\
                         'clockSwith',\
                         'clockHour',\
                         'clockMinute',\
                         'clockInterval',\
                         'sportSwith',\
                         'startTime',\
                         'endTime',\
                         'sportInterval',\
                         'target')\
                         VALUES (\
                         '%@',\
                         '%@',\
                         '%@',\
                         '%@',\
                         '%@',\
                         '%@',\
                         '%@',\
                         '%@',\
                         '%@',\
                         '%@',\
                         '%@',\
                         '%@',\
                         '%@',\
                         '%@',\
                         '%@',\
                         '%@')",
                         CurrentUser.userId,
                         model.nickName,
                         model.gender,
                         model.age,
                         @(model.height),
                         @(model.weight),
                         @(model.distance),
                         @(model.clockSwith),
                         @(model.clockHour),
                         @(model.clockMinute),
                         @(model.clockInterval),
                         @(model.sportSwith),
                         @(model.startTime),
                         @(model.endTime),
                         @(model.sportInterval),
                         @(model.target)];
        success = [db executeUpdate:sql];
    }];
    return success;
}

+ (BasicInfomationModel *)selectBasicInfomation {
    __block BasicInfomationModel *model;
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM 'basic_infomation_table' WHERE user_id = '%@'",CurrentUser.userId];
        FMResultSet *result = [db executeQuery:sql];
        if (result.next) {
            model = [[BasicInfomationModel alloc] init];
            model.height = [result intForColumn:@"height"];
            model.weight = [result intForColumn:@"weight"];
            model.distance = [result intForColumn:@"distance"];
            model.clockSwith = [result intForColumn:@"clockSwith"];
            model.clockHour = [result intForColumn:@"clockHour"];
            model.clockMinute = [result intForColumn:@"clockMinute"];
            model.clockInterval = [result intForColumn:@"clockInterval"];
            model.sportSwith = [result intForColumn:@"sportSwith"];
            model.startTime = [result intForColumn:@"startTime"];
            model.endTime = [result intForColumn:@"endTime"];
            model.sportInterval = [result intForColumn:@"sportInterval"];
            model.target = [result intForColumn:@"target"];
        }
    }];
    return model;
}


+ (BOOL)insertOrReplaceSportData:(SportDataModel *)model {
    __block BOOL success = NO;
    [dbQueue inDatabase:^(FMDatabase *db) {
        success = [self insertOrReplaceSportData:model database:db];
    }];
    return success;
}

+ (BOOL)insertOrReplaceSportData:(SportDataModel *)model database:(FMDatabase *)db {
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO 'sport_table' (\
                     'user_id',\
                     'step',\
                     'distance',\
                     'calorie',\
                     'target',\
                     'battery')\
                     VALUES (\
                     '%@',\
                     '%@',\
                     '%@',\
                     '%@',\
                     '%@',\
                     '%@')",
                     CurrentUser.userId,
                     @(model.step),
                     @(model.distance),
                     @(model.calorie),
                     @(model.target),
                     @(model.battery)];
    return [db executeUpdate:sql];
}

+ (SportDataModel *)selectSportData {
    __block SportDataModel *model;
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM 'sport_table' WHERE user_id = '%@'",CurrentUser.userId];
        FMResultSet *result = [db executeQuery:sql];
        if (result.next) {
            model = [[SportDataModel alloc] init];
            model.step = [result intForColumn:@"step"];
            model.distance = [result intForColumn:@"distance"];
            model.calorie = [result intForColumn:@"calorie"];
            model.target = [result intForColumn:@"target"];
            model.battery = [result intForColumn:@"battery"];
        }
    }];
    return model;
}

+ (BOOL)insertOrReplaceHistroySportData:(HistroySportDataModel *)model {
    __block BOOL success = NO;
    [dbQueue inDatabase:^(FMDatabase *db) {
        success = [self insertOrReplaceHistroySportData:model database:db];
    }];
    return success;
}

+ (BOOL)insertOrReplaceHistroySportData:(HistroySportDataModel *)model database:(FMDatabase *)db {
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO 'histroy_sport_table' (\
                     'user_id',\
                     'time',\
                     'calorie',\
                     'sleep',\
                     'battery',\
                     'date')\
                     VALUES (\
                     '%@',\
                     '%@',\
                     '%@',\
                     '%@',\
                     '%@',\
                     '%@')",
                     CurrentUser.userId,
                     @(model.time),
                     @(model.calorie),
                     @(model.sleep),
                     @(model.battery),
                     model.date];
    return [db executeUpdate:sql];
}

+ (HistroySportDataModel *)selectHistroySportDataByTime:(NSInteger)time {
    __block HistroySportDataModel *model;
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM 'histroy_sport_table' WHERE user_id = '%@'",CurrentUser.userId];
        FMResultSet *result = [db executeQuery:sql];
        if (result.next) {
            model = [[HistroySportDataModel alloc] init];
            model.time = [result intForColumn:@"time"];
            model.calorie = [result intForColumn:@"calorie"];
            model.sleep = [result intForColumn:@"sleep"];
            model.battery = [result intForColumn:@"battery"];
            model.date = [result dateForColumn:@"date"];
        }
    }];
    return model;
}




@end
