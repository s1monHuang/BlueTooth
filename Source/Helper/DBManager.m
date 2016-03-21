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

//NSInteger step = (byte[2] << 8) + byte[1];              //步数
//NSInteger distance = (byte[4] << 8) + byte[3];          //距离
//NSInteger calorie = (byte[6] << 8) + byte[5];           //卡路里
//NSInteger target = (byte[8] << 8) + byte[7];            //目标
//NSInteger battery = byte[9];                            //电量

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

//    NSInteger time = byte[1];                               //前几个小时的数据
//NSInteger step = (byte[3] << 8) + byte[2];              //步数
//NSInteger calorie = (byte[5] << 8) + byte[4];           //卡路里
//NSInteger sleep = byte[6];                              //睡眠动作次数
//NSInteger battery = byte[7];                            //电量

+ (BOOL)createHistroySportDataTable:(FMDatabase *)db {
    NSString *createAppsSql = @"CREATE TABLE IF NOT EXISTS 'histroy_sport_table' (\
    'user_id' TEXT PRIMARY KEY NOT NULL ,\
    'time' INTEGER, 'step' INTEGER,\
    'calorie' INTEGER,\
    'sleep' INTEGER,\
    'battery' INTEGER,\
    'date' DATE)";
    return [db executeUpdate:createAppsSql];
}

+ (BOOL)insertOrReplaceSportData:(SportDataModel *)model database:(FMDatabase *)db {
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO 'sport_table' ('user_id',\
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

+ (SportDataModel *)selectSportDataBydatabase:(FMDatabase *)db {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM 'histroy_sport_table' WHERE user_id = '%@'",CurrentUser.userId];
    FMResultSet *result = [db executeQuery:sql];
    SportDataModel *model;
    if (result.next) {
        model = [[SportDataModel alloc] init];
        model.step = [result intForColumn:@"step"];
        model.distance = [result intForColumn:@"distance"];
        model.calorie = [result intForColumn:@"calorie"];
        model.target = [result intForColumn:@"target"];
        model.battery = [result intForColumn:@"battery"];
    }
    return model;
}

+ (BOOL)insertOrReplaceHistroySportData:(HistroySportDataModel *)model database:(FMDatabase *)db {
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO 'histroy_sport_table' ('user_id',\
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

+ (HistroySportDataModel *)selectHistroySportDataByTime:(NSInteger)time database:(FMDatabase *)db {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM 'histroy_sport_table' WHERE user_id = '%@' AND time = '%@'",CurrentUser.userId,@(time).stringValue];
    FMResultSet *result = [db executeQuery:sql];
    HistroySportDataModel *model;
    if (result.next) {
        model = [[HistroySportDataModel alloc] init];
        model.time = [result intForColumn:@"time"];
        model.calorie = [result intForColumn:@"calorie"];
        model.sleep = [result intForColumn:@"sleep"];
        model.battery = [result intForColumn:@"battery"];
        model.date = [result dateForColumn:@"date"];
    }
    return model;
}




@end
