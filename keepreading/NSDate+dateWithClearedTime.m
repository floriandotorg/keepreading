//
//  NSDate+dateWithClearedTime.m
//  keepreading
//
//  Created by Florian Kaiser on 08.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "NSDate+dateWithClearedTime.h"

@implementation NSDate (dateWithClearedTime)

- (NSDate*)dateWithClearedTime
{    
    return [[NSCalendar currentCalendar] dateFromComponents:[[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self]];
}

@end
