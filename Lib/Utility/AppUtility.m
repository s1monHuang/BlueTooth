//
//  AppUtility.m
//

#import "AppUtility.h"

@interface AppUtility ()

@end

@implementation AppUtility

+ (instancetype)shareInstance
{
    static AppUtility *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[self alloc] init];
    });
    return _shareInstance;
}

- (id)init
{
    self = [super init];
    return self;
}

#pragma mark - Instance mothod

- (NSString *)getStringOfDate:(NSDate *)date format:(NSString *)format
{
    if (!date) return nil;
    
    if (format && format.length > 0) {
        [self.dateFormatter setDateFormat:format];
    } else {
        [self.dateFormatter setDateFormat:kDateFormatDefault_];
    }
    
    return [self.dateFormatter stringFromDate:date];
}

- (NSString *)getStringOfDateString:(NSString *)dateString format:(NSString *)format
{
    if(!dateString || dateString.length == 0) return nil;
    
    [self.dateFormatter setDateFormat:kDateFormatDefault_];
    NSDate *newDate = [self.dateFormatter dateFromString:dateString];
    
    return [self getStringOfDate:newDate format:format];
}

- (NSDate *)getDateOfString:(NSString *)dateString format:(NSString *)format
{
    NSDate *dateRet = nil;
    if (dateString && dateString.length > 0) {
        [self.dateFormatter setDateFormat:format ?: kDateFormatDefault_];
        dateRet = [self.dateFormatter dateFromString:dateString];
    }
    
    return dateRet;
}

- (NSDateComponents *)dateComponentsFromDate:(NSDate *)date
{
    NSDateComponents *dateComp = nil;
    if (date) {
        NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        dateComp = [self.calender components:unitFlags fromDate:date];
    }
    return dateComp;
}

- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter == nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:kDateFormatDefault_];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CH"];
        [dateFormatter setLocale:usLocale];
        _dateFormatter=dateFormatter;
    }

    return _dateFormatter;
}

- (NSCalendar *)calender
{
    if (_calender == nil) {
        _calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    return _calender;
}

- (NSDate *)dateWithoutTimeFromDate:(NSDate*)date {
    if (!date) return nil;
    NSDateComponents* components = [self.calender components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    return [self.calender dateFromComponents:components];
}

- (NSComparisonResult)dateCompareWithFirstDay:(NSDate *)firstDate secondDay:(NSDate *)secondDate
{
    if (!firstDate || !secondDate) {
        return -2;
    }
    
    return [[self dateWithoutTimeFromDate:firstDate] compare:[self dateWithoutTimeFromDate:secondDate]];
}


@end
