//
//  FYDBook.h
//  keepreading
//
//  Created by Florian Kaiser on 30.05.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYDBook : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSDate *publishedDate;
@property (strong, nonatomic) NSString *publisher;
@property (assign, nonatomic) NSUInteger firstPage;
@property (assign, nonatomic) NSUInteger lastPage;
@property (strong, nonatomic) NSURL *thumbnailURL;
@property (strong, nonatomic) NSString *isbn;

- (void)loadThumbnail:(void(^)(UIImage*,NSError*))completionHandler;

@end
