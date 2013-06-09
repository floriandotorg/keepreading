//
//  NSDate+dateByAddDays.m
//  keepreading
//
//  Created by Florian Kaiser on 09.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "NSDate+dateByAddDays.h"

@implementation NSDate (dateByAddDays)

- (NSDate*)dateByAddDays:(NSInteger)days
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = days;
    
    return [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self options:0];
}

@end
