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
    [self.bookReadingArray addObject:[[FYDBookReading alloc] initWithBook:book]];
}

- (NSArray*)readingsForDate:(NSDate*)date
{
    return self.bookReadingArray;
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
