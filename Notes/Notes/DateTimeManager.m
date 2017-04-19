//
//  DateTimeManager.m
//  Notes
//
//  Created by Nemetschek A-Team on 4/5/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "DateTimeManager.h"

@interface DateTimeManager()

@property NSDateFormatter *dateFormatter;

@end

@implementation DateTimeManager

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"HH:mm:ss, dd-MM-yyyy"];
    }
    return self;
}

- (NSString *)convertToRelativeDate:(NSString *)stringDate
{
    NSString *result;
    NSDate *date = [self.dateFormatter dateFromString:stringDate];
    NSCalendarUnit units = NSCalendarUnitDay | NSCalendarUnitWeekOfYear |
    NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:[NSDate date]
                                                                     toDate:date
                                                                    options:0];
    
    if (components.year > 1){
        result = [NSString stringWithFormat:@"After %ld years", (long)components.year];
    }else if (components.year > 0){
        result = [NSString stringWithFormat:@"After %ld year", (long)components.year];
    }else if (components.month > 1){
        result = [NSString stringWithFormat:@"After %ld months", (long)components.month];
    }else if (components.month > 0){
        result = [NSString stringWithFormat:@"After %ld month", (long)components.month];
    }else if (components.weekOfYear > 1){
        result = [NSString stringWithFormat:@"After %ld weeks", (long)components.weekOfYear];
    }else if (components.weekOfYear > 0){
        result = [NSString stringWithFormat:@"After %ld week", (long)components.weekOfYear];
    }else if (components.day > 1){
        result = [NSString stringWithFormat:@"After %ld days", (long)components.day];
    }else if (components.day > 0){
        result = @"Tomorrow";
    }else{
        result = @"Today";
    }
    return result;
}

- (NSComparisonResult)compareStringDate:(NSString *)firstDate andDate:(NSString *)secondDate
{
    NSDate *first = [self.dateFormatter dateFromString:firstDate];
    NSDate *second = [self.dateFormatter dateFromString:secondDate];
    return [first compare:second] == NSOrderedDescending;
};

-(NSString*) getCurrentTime
{
    return [self.dateFormatter stringFromDate:[NSDate date]];
}

@end
