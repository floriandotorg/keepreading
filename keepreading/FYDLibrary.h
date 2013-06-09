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

- (void)addReading:(FYDBook*)book;
- (NSArray*)readingsForDate:(NSDate*)date;

@end
