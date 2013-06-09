//
//  FYDBookReadingDay.h
//  keepreading
//
//  Created by Florian Kaiser on 08.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import <Foundation/Foundation.h>

@class FYDBookReading;

@interface FYDBookReadingDay : NSObject

@property (weak, readonly, nonatomic) FYDBookReading *bookReading;

@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic, readonly) NSUInteger pagesRead;

- (id)initWithReading:(FYDBookReading*)reading;

- (NSRange)pageRange;

- (FYDBookReadingDay*)next;
- (FYDBookReadingDay*)prev;

@end
