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
    STAssertNoThrow([FYDBookSearch search:@"Fear and loathing" completionHandler:^(NSArray *results, NSError *error)
                     {
                         STAssertNil(error, @"search has error");
                         dispatch_semaphore_signal(sema);
                     }], @"FYDBookSearch search did throw");
    
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    
    STAssertTrue(dispatch_semaphore_wait(sema, DISPATCH_TIME_NOW) == 0, @"callback has not been called");
}

- (void)testModel
{
    [self.library addBook:[[FYDBook alloc] init]];
}

@end
