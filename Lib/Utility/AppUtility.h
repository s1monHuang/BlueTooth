//
//  AppUtility.h
//

#import <Foundation/Foundation.h>

#define kDateFormatDefault_              @"yyyy-MM-dd HH:mm:ss"
#define kDateFormatWithoutTime_          @"yyyy-MM-dd"


@interface AppUtility : NSObject

+ (instancetype) shareInstance;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSCalendar *calender;

#pragma mark - Instance mothod
#pragma mark - Date 相关

// Date和String的相关转换
- (NSString *)getStringOfDate:(NSDate *)date format:(NSString *)format;
- (NSString *)getStringOfDateString:(NSString *)dateString format:(NSString *)format;
- (NSDate *)getDateOfString:(NSString *)dateString format:(NSString *)format;

// 单日期，没有时间
- (NSDate *)dateWithoutTimeFromDate:(NSDate *)date;

// 比较两个日期，从天开始比较
- (NSComparisonResult)dateCompareWithFirstDay:(NSDate *)firstDate secondDay:(NSDate *)secondDate; 

// 获取年到秒的NSDateComponents
- (NSDateComponents *)dateComponentsFromDate:(NSDate *)date;

@end
