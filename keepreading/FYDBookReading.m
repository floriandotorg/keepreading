//
//  FYDBookReading.m
//  keepreading
//
//  Created by Florian Kaiser on 08.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDBookReading.h"

@interface FYDBookReadingDay ()

@property (weak, nonatomic) FYDBookReading *bookReading;
@property (assign, nonatomic, readonly) NSUInteger pageNo;

@end

@interface FYDBookReading ()

@property (strong, nonatomic) FYDBook *book;
@property (strong, nonatomic) NSMutableDictionary *dayArray;

@end

@implementation FYDBookReading

- (id)initWithBook:(FYDBook*)book
{
    if (self = [super init])
    {
        self.book = book;
        self.dayArray = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (FYDBookReadingDay*)dayForDate:(NSDate*)date
{
    FYDBookReadingDay *day = self.dayArray[date];
    
    if (day == nil)
    {
        day = [[FYDBookReadingDay alloc] initWithReading:self];
        self.dayArray[date] = day;
    }
    
    return day;
}

- (FYDBookReadingDay*)previousDay:(FYDBookReadingDay*)day
{
    NSArray *dateArray = [self.dayArray.allKeys sortedArrayUsingComparator:^(id obj1, id obj2)
                          {
                              return [obj2 compare:obj1];
                          }];
    
    NSInteger index = [dateArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
                       {
                           *stop = NO;
                           
                           if ([obj compare:[self.dayArray allKeysForObject:day][0]] == NSOrderedAscending && [(FYDBookReadingDay*)self.dayArray[obj] pageNo] != 0)
                           {
                               return YES;
                           }
                           else
                           {
                               return NO;
                           }
                       }];
    
    if (index != NSNotFound)
    {
        return self.dayArray[dateArray[index]];
    }
    else
    {
        return nil;
    }
}

- (FYDBookReadingDay*)nextDay:(FYDBookReadingDay*)day
{
    NSArray *dateArray = [self.dayArray.allKeys sortedArrayUsingComparator:^(id obj1, id obj2)
                          {
                              return [obj2 compare:obj1];
                          }];
    
    NSInteger index = [dateArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
                       {
                           *stop = NO;
                           
                           if ([obj compare:[self.dayArray allKeysForObject:day][0]] == NSOrderedDescending && [(FYDBookReadingDay*)self.dayArray[obj] pageNo] != 0)
                           {
                               return YES;
                           }
                           else
                           {
                               return NO;
                           }
                       }];
    
    if (index != NSNotFound)
    {
        return self.dayArray[dateArray[index]];
    }
    else
    {
        return nil;
    }
}

#pragma mark - Persistent State

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.book forKey:@"book"];
    [aCoder encodeObject:self.dayArray forKey:@"dayArray"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.book = [aDecoder decodeObjectForKey:@"book"];
        self.dayArray = [aDecoder decodeObjectForKey:@"dayArray"];
        
        for (NSDate *date in self.dayArray)
        {
            [self.dayArray[date] setBookReading:self];
        }
    }
    return self;
}

@end
