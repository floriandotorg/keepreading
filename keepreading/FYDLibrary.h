//
//  FYDLibrary.h
//  keepreading
//
//  Created by Florian Kaiser on 30.05.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import <Foundation/Foundation.h>

@class FYDBook;

@interface FYDLibrary : NSObject

@property (assign, nonatomic) NSUInteger goal;

- (void)addReading:(FYDBook*)book;
- (NSArray*)readingsForDate:(NSDate*)date;
- (NSUInteger)pagesReadAtDate:(NSDate*)date;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
