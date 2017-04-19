//
//  DateTimeManager.h
//  Notes
//
//  Created by Nemetschek A-Team on 4/5/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateTimeManager : NSObject

- (NSString *)convertToRelativeDate:(NSString *)stringDate;

- (NSComparisonResult)compareStringDate:(NSString *)firstDate andDate:(NSString *)secondDate;

-(NSString*) getCurrentTime;
@end
