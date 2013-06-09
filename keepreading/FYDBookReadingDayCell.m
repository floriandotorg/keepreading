//
//  FYDBookReadingDayCell.m
//  keepreading
//
//  Created by Florian Kaiser on 08.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDBookReadingDayCell.h"

#import "FYDBookReading.h"
#import "FYDBook.h"

@interface FYDBookReadingDayCell ()

@property (weak, nonatomic) IBOutlet UILabel *currentPageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayPagesReadLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@end

@implementation FYDBookReadingDayCell

- (void)setBookReadingDay:(FYDBookReadingDay *)bookReadingDay
{
    _bookReadingDay = bookReadingDay;
    
    self.titleLabel.text = bookReadingDay.bookReading.book.title;
    
    [bookReadingDay.bookReading.book loadThumbnail:^(UIImage *image, NSError *error)
        {
            self.thumbnailImageView.image = image;
        }];
    
    self.currentPageLabel.text = [NSString stringWithFormat:@"%i", bookReadingDay.currentPage];
    self.dayPagesReadLabel.text = [NSString stringWithFormat:@"%i", bookReadingDay.pagesRead];
}

@end
