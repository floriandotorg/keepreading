//
//  keepreadingTests.m
//  keepreadingTests
//
//  Created by Florian Kaiser on 30.05.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "keepreadingTests.h"

#import "FYDLibrary.h"
#import "FYDBook.h"
#import "FYDBookSearch.h"
#import "FYDBookReading.h"
#import "FYDBookReadingDay.h"

#import "NSDate+dateWithClearedTime.h"
#import "NSDate+dateByAddDays.h"

@interface keepreadingTests ()
{
    dispatch_semaphore_t sema;
}

@property (strong, nonatomic) FYDLibrary *library;

@end

@implementation keepreadingTests

- (void)setUp
{
    [super setUp];
    
    self.library = [[FYDLibrary alloc] init];
    sema = dispatch_semaphore_create(0);
}

- (void)tearDown
{
    self.library = nil;
    
    [super tearDown];
}

- (void)testBookSearch
{
//    STAssertNoThrow([FYDBookSearch search:@"Fear and loathing" completionHandler:^(NSArray *results, NSError *error)
//                     {
//                         STAssertNil(error, @"search has error");
//                         dispatch_semaphore_signal(sema);
//                     }], @"FYDBookSearch search did throw");
//    
//    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
//    
//    STAssertTrue(dispatch_semaphore_wait(sema, DISPATCH_TIME_NOW) == 0, @"callback has not been called");
}

- (void)testModel
{
    FYDBook *book = [[FYDBook alloc] init];
    book.title = @"Test Book";
    book.firstPage = 1;
    book.lastPage = 100;
    [self.library addReading:book];
    
    NSDate *date = [[NSDate date] dateWithClearedTime];
    
    FYDBookReading *reading = [self.library readingsForDate:date][0];

    FYDBookReadingDay *prevDay = [reading dayForDate:[date dateByAddDays:-1]];
    FYDBookReadingDay *day = [reading dayForDate:date];
    FYDBookReadingDay *nextDay = [reading dayForDate:[date dateByAddDays:1]];
    
    day.pageNo = 10;
    
    ////////// pageRange
    
    STAssertTrue(NSEqualRanges(prevDay.pageRange, NSMakeRange(1, 9)), [NSString stringWithFormat:@"prevDay.pageRange == %@", NSStringFromRange(prevDay.pageRange)]);
    
    STAssertTrue(NSEqualRanges(day.pageRange, NSMakeRange(1, 100)), [NSString stringWithFormat:@"day.pageRange == %@", NSStringFromRange(day.pageRange)]);
    
    STAssertTrue(NSEqualRanges(nextDay.pageRange, NSMakeRange(10, 100)), [NSString stringWithFormat:@"nextDaypageRange == %@", NSStringFromRange(nextDay.pageRange)]);
    
    ////////// pagesRead
    
    STAssertEquals(prevDay.pagesRead, (NSUInteger)0, [NSString stringWithFormat:@"prevDay.pagesRead == %i", prevDay.pagesRead]);
    STAssertEquals(day.pagesRead, (NSUInteger)10, [NSString stringWithFormat:@"day.pagesRead == %i", day.pagesRead]);
    STAssertEquals(nextDay.pagesRead, (NSUInteger)0, [NSString stringWithFormat:@"nextDay.pagesRead == %i", nextDay.pagesRead]);
}

@end
