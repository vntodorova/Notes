//
//  DateTimeManager.m
//  Notes
//
//  Created by Nemetschek A-Team on 4/5/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "DateTimeManager.h"

#define DATE_FORMAT                     @"yyyy-MM-dd HH:mm:ss ZZZZ"
#define MESSAGE_TIME_REMAINING_YEARS    @"After %ld years"
#define MESSAGE_TIME_REMAINING_YEAR     @"After %ld year"
#define MESSAGE_TIME_REMAINING_MONTHS   @"After %ld months"
#define MESSAGE_TIME_REMAINING_MONTH    @"After %ld month"
#define MESSAGE_TIME_REMAINING_WEEKS    @"After %ld weeks"
#define MESSAGE_TIME_REMAINING_WEEK     @"After %ld week"
#define MESSAGE_TIME_REMAINING_DAYS     @"After %ld days"
#define MESSAGE_TIME_REMAINING_TOMORROW @"Tomorrow"
#define MESSAGE_TIME_REMAINING_TODAY    @"Today"

@interface DateTimeManager()
@property NSDateFormatter *dateFormatter;
@end

static DateTimeManager *sharedInstance = nil;

@implementation DateTimeManager

+ (DateTimeManager *)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [self.dateFormatter setLocale:[NSLocale currentLocale]];
        [self.dateFormatter setDateFormat:DATE_FORMAT];
        [self.dateFormatter setFormatterBehavior:NSDateFormatterBehaviorDefault];
    }
    return self;
}

- (NSString *)convertToRelativeDate:(NSString *)stringDate
{
    NSDate *date = [self.dateFormatter dateFromString:stringDate];
    NSCalendarUnit units = NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:[NSDate date]
                                                                     toDate:date
                                                                    options:0];
    return [DateTimeManager getUIStringFromDateComponents:components];
}

+ (NSString *)getUIStringFromDateComponents:(NSDateComponents *)components
{
    NSString *result;
    if (components.year > 1)
    {
        result = [NSString stringWithFormat:MESSAGE_TIME_REMAINING_YEARS, (long)components.year];
    }
    else if (components.year > 0)
    {
        result = [NSString stringWithFormat:MESSAGE_TIME_REMAINING_YEAR, (long)components.year];
    }
    else if (components.month > 1)
    {
        result = [NSString stringWithFormat:MESSAGE_TIME_REMAINING_MONTHS, (long)components.month];
    }
    else if (components.month > 0)
    {
        result = [NSString stringWithFormat:MESSAGE_TIME_REMAINING_MONTH, (long)components.month];
    }
    else if (components.weekOfYear > 1)
    {
        result = [NSString stringWithFormat:MESSAGE_TIME_REMAINING_WEEKS, (long)components.weekOfYear];
    }
    else if (components.weekOfYear > 0)
    {
        result = [NSString stringWithFormat:MESSAGE_TIME_REMAINING_WEEK, (long)components.weekOfYear];
    }
    else if (components.day > 1)
    {
        result = [NSString stringWithFormat:MESSAGE_TIME_REMAINING_DAYS, (long)components.day];
    }
    else if (components.day > 0)
    {
        result = MESSAGE_TIME_REMAINING_TOMORROW;
    }
    else
    {
        result = MESSAGE_TIME_REMAINING_TODAY;
    }
    return result;
}

- (NSComparisonResult)compareStringDate:(NSString *)firstDate andDate:(NSString *)secondDate
{
    NSDate *first = [self.dateFormatter dateFromString:firstDate];
    NSDate *second = [self.dateFormatter dateFromString:secondDate];
    return [first compare:second] == NSOrderedDescending;
}

- (NSString *)getCurrentTime
{
    return [self.dateFormatter stringFromDate:[NSDate date]];
}

- (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format
{
    [self.dateFormatter setDateFormat:format];
    NSDate *result = [self.dateFormatter dateFromString:string];
    [self.dateFormatter setDateFormat:DATE_FORMAT];
    return result;
}

@end
