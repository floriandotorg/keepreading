//
//  FYDBook.m
//  keepreading
//
//  Created by Florian Kaiser on 30.05.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDBook.h"

@interface FYDBook ()

@property (strong, nonatomic) UIImage *thumbnail;

@end

@implementation FYDBook

- (void)setThumbnailURL:(NSURL *)thumbnailURL
{
    _thumbnailURL = thumbnailURL;
    self.thumbnail = nil;
}

- (void)loadThumbnail:(void(^)(UIImage*,NSError*))completionHandler
{
    if (self.thumbnail == nil)
    {
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:self.thumbnailURL]
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             if (error == nil)
             {
                 self.thumbnail = [UIImage imageWithData:data];
                 completionHandler(self.thumbnail, nil);
             }
             else
             {
                 completionHandler(nil, error);
             }
         }];
    }
    else
    {
        completionHandler(self.thumbnail, nil);
    }
}

@end
