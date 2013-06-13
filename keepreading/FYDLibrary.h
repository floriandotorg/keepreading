//
//  FYDLibrary.h
//  keepreading
//
//  Created by Florian Kaiser on 30.05.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import <Foundation/Foundation.h>

@class FYDBook;
@class FYDBookReading;

@interface FYDLibrary : NSObject

@property (assign, nonatomic) NSUInteger goal;

- (void)addReading:(FYDBook*)book;
- (NSArray*)readingsForDate:(NSDate*)date;
- (FYDBookReading*)readingNo:(NSUInteger)no ForDate:(NSDate*)date;
- (void)moveReadingNo:(NSUInteger)from toNo:(NSUInteger)to AtDate:(NSDate*)date;
- (void)deleteReading:(NSUInteger)no  AtDate:(NSDate*)date;
- (NSUInteger)pagesReadAtDate:(NSDate*)date;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
