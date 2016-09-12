//
//  DBManager.m
//  BlueToothBracelet
//
//  Created by snhuang on 16/3/18.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "DBManager.h"
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

+ (BOOL)createBasicInfomationTable:(FMDatabase *)db {
    NSString *createAppsSql = @"CREATE TABLE IF NOT EXISTS 'basic_infomation_table' (\
    'user_id' TEXT PRIMARY KEY NOT NULL ,\
    'nick_name' TEXT,\
    'gender' TEXT,\
    'age' TEXT,\
    'height' INTEGER,\
    'weight' INTEGER,\
    'distance' INTEGER,\
    'clockSwitch' INTEGER,\
    'clockHour' INTEGER,\
    'clockMinute' INTEGER,\
    'clockInterval' INTEGER,\
    'sportSwitch' INTEGER,\
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
    'step' INTEGER,\
    'time' INTEGER,\
    'calorie' INTEGER,\
    'sleep' INTEGER,\
    'battery' INTEGER,\
    'date' DATE,\
    PRIMARY KEY ('user_id' , 'date'))";
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
                         'clockSwitch',\
                         'clockHour',\
                         'clockMinute',\
                         'clockInterval',\
                         'sportSwitch',\
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
                         @(model.clockSwitch),
                         @(model.clockHour),
                         @(model.clockMinute),
                         @(model.clockInterval),
                         @(model.sportSwitch),
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
            model.nickName = [result stringForColumn:@"nick_name"];
            model.gender = [result stringForColumn:@"gender"];
            model.age = [result stringForColumn:@"age"];
            model.height = [result intForColumn:@"height"];
            model.weight = [result intForColumn:@"weight"];
            model.distance = [result intForColumn:@"distance"];
            model.clockSwitch = [result intForColumn:@"clockSwitch"];
            model.clockHour = [result intForColumn:@"clockHour"];
            model.clockMinute = [result intForColumn:@"clockMinute"];
            model.clockInterval = [result intForColumn:@"clockInterval"];
            model.sportSwitch = [result intForColumn:@"sportSwitch"];
            model.startTime = [result intForColumn:@"startTime"];
            model.endTime = [result intForColumn:@"endTime"];
            model.sportInterval = [result intForColumn:@"sportInterval"];
            model.target = [result intForColumn:@"target"];
            [result close];
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
            [result close];
        }
    }];
    return model;
}

+ (BOOL)insertOrReplaceHistroySportData:(HistorySportDataModel *)model {
    __block BOOL success = NO;
    [dbQueue inDatabase:^(FMDatabase *db) {
        success = [self insertOrReplaceHistroySportData:model database:db];
    }];
    return success;
}

+ (BOOL)insertOrReplaceHistroySportData:(HistorySportDataModel *)model database:(FMDatabase *)db {
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO 'histroy_sport_table' (\
                     'user_id',\
                     'step',\
                     'time',\
                     'calorie',\
                     'step',\
                     'sleep',\
                     'battery',\
                     'date')\
                     VALUES (\
                     '%@',\
                     '%@',\
                     '%@',\
                     '%@',\
                     '%@',\
                     '%@',\
                     '%@',\
                     '%@')",
                     CurrentUser.userId,
                     @(model.step),
                     @(model.time),
                     @(model.calorie),
                     @(model.step),
                     @(model.sleep),
                     @(model.battery),
                     model.date];
    return [db executeUpdate:sql];
}

+ (HistorySportDataModel *)selectHistorySportDataByTime:(NSInteger)time {
    __block HistorySportDataModel *model;
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
        [db setDateFormat:formatter];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM 'histroy_sport_table' WHERE user_id = '%@'",CurrentUser.userId];
        FMResultSet *result = [db executeQuery:sql];
        if (result.next) {
            model = [[HistorySportDataModel alloc] init];
            model.time = [result intForColumn:@"time"];
            model.calorie = [result intForColumn:@"calorie"];
            model.sleep = [result intForColumn:@"sleep"];
            model.battery = [result intForColumn:@"battery"];
            model.date = [result dateForColumn:@"date"];
            model.step = [result intForColumn:@"step"];
            [result close];
        }
    }];
    return model;
}

+ (NSArray *)selectOneDayHistorySportData {
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
        [db setDateFormat:formatter];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM 'histroy_sport_table' WHERE user_id = '%@' ORDER BY time ASC LIMIT 24",CurrentUser.userId];
        FMResultSet *result = [db executeQuery:sql];
        while (result.next) {
            HistorySportDataModel *model = [[HistorySportDataModel alloc] init];
            model.time = [result intForColumn:@"time"];
            model.calorie = [result intForColumn:@"calorie"];
            model.sleep = [result intForColumn:@"sleep"];
            model.battery = [result intForColumn:@"battery"];
            model.date = [result dateForColumn:@"date"];
            model.step = [result intForColumn:@"step"];
            [array addObject:model];
        }
        [result close];
    }];
    return array;
}

+ (NSInteger)selectTodayStepNumber {
    __block NSInteger stepNumber = 0;
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM 'sport_table' WHERE user_id = '%@'",CurrentUser.userId];
        FMResultSet *result = [db executeQuery:sql];
        while (result.next) {
            stepNumber += [result intForColumn:@"step"];
        }
        [result close];
    }];
    return stepNumber;
}

+ (NSInteger)selectTodayssmNumber {
    __block NSInteger ssmNumber = 0;
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM 'histroy_sport_table' WHERE user_id = '%@' AND date > date('now') AND date < date('now','start of day','1 day')",CurrentUser.userId];
        FMResultSet *result = [db executeQuery:sql];
        while (result.next) {
            NSInteger sleep = [result intForColumn:@"sleep"];
            if (sleep < 10) {
                ssmNumber += 1;
            }
        }
        [result close];
    }];
    return ssmNumber;
}

+ (NSInteger)selectTodayqsmNumber {
    __block NSInteger qsmNumber = 0;
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM 'histroy_sport_table' WHERE user_id = '%@' AND date > date('now') AND date < date('now','start of day','1 day')",CurrentUser.userId];
        FMResultSet *result = [db executeQuery:sql];
        while (result.next) {
            NSInteger sleep = [result intForColumn:@"sleep"];
            if (sleep >= 10 && sleep < 255) {
                qsmNumber += 1;
            }
        }
        [result close];
    }];
    return qsmNumber;
}



+ (NSString *)selectHistorySleepData {
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        for (NSInteger i = 0; i < 3; i++) {
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM 'histroy_sport_table' WHERE user_id = '%@' AND date > date('now','start of day','%@ day') AND date < date('now','start of day','%@ day')",CurrentUser.userId,@(i - 2).stringValue,@(i - 1).stringValue];
            FMResultSet *result = [db executeQuery:sql];
            
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            NSInteger ssmTime = 0;
            NSInteger qsmTime = 0;
            
            NSDate *date = [NSDate dateWithTimeInterval:(3600 * 24) * (i - 2) sinceDate:[NSDate date]];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSString *dateString = [formatter stringFromDate:date];
            
            while (result.next) {
                NSInteger sleep = [result intForColumn:@"sleep"];
                if (sleep < 10) {
                    ssmTime += 1;
                } else if (sleep >= 10 && sleep < 255) {
                    qsmTime += 1;
                }
            }
            
            [dictionary setObject:@(ssmTime).stringValue forKey:@"ssmTime"];
            [dictionary setObject:@(qsmTime).stringValue forKey:@"qsmTime"];
            [dictionary setObject:dateString forKey:@"sleepDate"];
            
            [array addObject:dictionary];
            
            [result close];
        }
    }];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSString *)testSelectHistorySleepData {
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
        [db setDateFormat:formatter];
        
        for (NSInteger i = 0; i < 3; i++) {
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM 'histroy_sport_table' WHERE user_id = '%@' AND date > date('now','start of day','%@ day') AND date < date('now','start of day','%@ day')",CurrentUser.userId,@(i - 2).stringValue,@(i - 1).stringValue];
            FMResultSet *result = [db executeQuery:sql];
//            NSInteger ssmTime = 0;
//            NSInteger qsmTime = 0;
            
//            NSDate *date = [NSDate dateWithTimeInterval:(3600 * 24) * (i - 2) sinceDate:[NSDate date]];
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            [formatter setDateFormat:@"yyyy-MM-dd"];
//            NSString *dateString = [formatter stringFromDate:date];
            
            while (result.next) {
                
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
                NSInteger ssmTime = 0;
                NSInteger qsmTime = 0;
                NSInteger sleep = [result intForColumn:@"sleep"];
                
                if (sleep < 10) {
                    ssmTime += 1;
                } else if (sleep >= 10 && sleep < 255) {
                    qsmTime += 1;
                }
                
                NSDate *date1 = [result dateForColumn:@"date"];
                
                NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
                [formatter1 setDateFormat:@"yyyy-MM-dd"];
                NSString *dateString1 = [formatter1 stringFromDate:date1];
                
                [dictionary setObject:@(ssmTime).stringValue forKey:@"ssmTime"];
                [dictionary setObject:@(qsmTime).stringValue forKey:@"qsmTime"];
                [dictionary setObject:@(sleep).stringValue forKey:@"actionNumber"];
                
                [dictionary setObject:dateString1 forKey:@"sleepDate"];
                
                [array addObject:dictionary];
            }
            
            [result close];
        }
    }];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


+ (NSString *)selectHistorySportData {
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        for (NSInteger i = 0; i < 3; i++) {
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM 'histroy_sport_table' WHERE user_id = '%@' AND date > date('now','start of day','%@ day') AND date < date('now','start of day','%@ day')",CurrentUser.userId,@(i - 2).stringValue,@(i - 1).stringValue];
            
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            
            NSInteger stepNum = 0;
            
            NSDate *date = [NSDate dateWithTimeInterval:(3600 * 24) * (i - 2) sinceDate:[NSDate date]];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSString *dateString = [formatter stringFromDate:date];
            
            FMResultSet *result = [db executeQuery:sql];
            while (result.next) {
                stepNum += [result intForColumn:@"step"];
                NSLog(@"stepNum = %@",@([result intForColumn:@"step"]).stringValue);
            }
            
            [dictionary setObject:@(stepNum).stringValue forKey:@"stepNum"];
            [dictionary setObject:dateString forKey:@"recordDate"];
            
            [array addObject:dictionary];
            
            [result close];
        }
    }];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSDate *)selectNewestHistoryData
{
    __block NSDate *date;
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
        [db setDateFormat:formatter];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT date FROM 'histroy_sport_table' WHERE user_id = '%@' ORDER BY date DESC LIMIT 1",CurrentUser.userId];
        FMResultSet *result = [db executeQuery:sql];
        if (result.next) {
            date = [result dateForColumn:@"date"];
        }
        [result close];
        
    }];
    return date;
    
}

+ (NSInteger)selectSportHistoryDataCount {
    __block NSInteger number;
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
        [db setDateFormat:formatter];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM 'histroy_sport_table' WHERE user_id = '%@'",CurrentUser.userId];
        number = [db intForQuery:sql];
        
    }];
    return number;
}

+ (BOOL)deleteAllSportData {
    __block BOOL success = NO;
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *deleteHistorySql = [NSString stringWithFormat:@"DELETE FROM 'histroy_sport_table'"];
        NSString *deleteSportSql = [NSString stringWithFormat:@"DELETE FROM 'sport_table'"];
        if ([db executeUpdate:deleteSportSql] && [db executeUpdate:deleteHistorySql]) {
            success = YES;
        }
    }];
    return success;
}


@end
