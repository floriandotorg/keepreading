//
//  FYDBookReading.h
//  keepreading
//
//  Created by Florian Kaiser on 08.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FYDBook.h"
#import "FYDBookReadingDay.h"

@interface FYDBookReading : NSObject

@property (strong, readonly, nonatomic) FYDBook *book;

- (id)initWithBook:(FYDBook*)book;

- (FYDBookReadingDay*)dayForDate:(NSDate*)date;

- (FYDBookReadingDay*)previousDay:(FYDBookReadingDay*)day;
- (FYDBookReadingDay*)nextDay:(FYDBookReadingDay*)day;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
