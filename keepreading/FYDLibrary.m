//
//  FYDLibrary.m
//  keepreading
//
//  Created by Florian Kaiser on 30.05.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDLibrary.h"

#import "FYDBook.h"
#import "FYDBookReading.h"

@interface FYDLibrary ()

@property (strong, nonatomic) NSMutableArray *bookReadingArray;

@end

@implementation FYDLibrary

- (id)init
{
    if (self = [super init])
    {
        self.bookReadingArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addReading:(FYDBook*)book
{
    if ([self.bookReadingArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) { return [(FYDBookReading*)obj book] == book; }] == NSNotFound)
    {
        [self.bookReadingArray addObject:[[FYDBookReading alloc] initWithBook:book]];
    } 
}

- (NSArray*)readingsForDate:(NSDate*)date
{
    return self.bookReadingArray;
}

- (FYDBookReading*)readingNo:(NSUInteger)no ForDate:(NSDate*)date
{
    return self.bookReadingArray[no];
}

- (void)moveReadingNo:(NSUInteger)from toNo:(NSUInteger)to AtDate:(NSDate*)date
{
    [self.bookReadingArray exchangeObjectAtIndex:from withObjectAtIndex:to];
}

- (void)deleteReading:(NSUInteger)no  AtDate:(NSDate*)date
{
    [self.bookReadingArray removeObjectAtIndex:no];
}

- (NSUInteger)pagesReadAtDate:(NSDate*)date
{
    NSUInteger result = 0;
    
    for (FYDBookReading *reading in [self readingsForDate:date])
    {
        result += [reading dayForDate:date].pagesRead;
    }
    
    return result;
}

#pragma mark - Persistent State

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.goal forKey:@"goal"];
    [aCoder encodeObject:self.bookReadingArray forKey:@"bookReadingArray"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.goal = [aDecoder decodeIntegerForKey:@"goal"];
        self.bookReadingArray = [aDecoder decodeObjectForKey:@"bookReadingArray"];
    }
    return self;
}

@end
