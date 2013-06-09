//
//  FYDBookReadingDay.m
//  keepreading
//
//  Created by Florian Kaiser on 08.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDBookReadingDay.h"

#import "FYDBookReading.h"

@interface FYDBookReadingDay ()

@property (weak, nonatomic) FYDBookReading *bookReading;
@property (assign, nonatomic) NSUInteger pageNo;

@end

@implementation FYDBookReadingDay

- (id)initWithReading:(FYDBookReading*)reading
{
    if (self = [super init])
    {
        self.bookReading = reading;
    }
    return self;
}

- (FYDBookReadingDay*)next
{
    return [self.bookReading nextDay:self];
}

- (FYDBookReadingDay*)prev
{
    return [self.bookReading previousDay:self];
}

- (NSRange)pageRange
{
    NSUInteger loc = self.prev.pageNo;
    NSUInteger len = self.next.pageNo;
    
    if (loc == 0)
    {
        loc = self.bookReading.book.firstPage;
    }
    
    if (len == 0)
    {
        len = self.bookReading.book.lastPage;
    }
    else
    {
        len = len  - 1;
    }
    
    return NSMakeRange(loc, len);
}

- (NSUInteger)currentPage
{
    if (self.pageNo == 0)
    {
        FYDBookReadingDay *prevDay = self.prev;
        
        if (prevDay == nil)
        {
            return self.pageRange.location;
        }
        else
        {
            return prevDay.currentPage;
        }
    }
    else
    {
        return self.pageNo;
    }
}

- (void)setCurrentPage:(NSUInteger)currentPage
{
    if (currentPage != self.pageRange.location)
    {
        self.pageNo = currentPage;
    }
    else
    {
        self.pageNo = 0;
    }
}

- (NSUInteger)pagesRead
{
    if (self.pageNo == 0)
    {
        return 0;
    }
    else
    {
        FYDBookReadingDay *prevDay = self.prev;
        
        if (prevDay == nil)
        {
            return self.pageNo - self.bookReading.book.firstPage;
        }
        else
        {
            return self.pageNo - self.prev.pageNo;
        }
    }
}

@end
