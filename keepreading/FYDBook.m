//
//  FYDBook.m
//  keepreading
//
//  Created by Florian Kaiser on 30.05.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDBook.h"

@interface FYDBook ()

@property (strong, nonatomic) NSURL *thumbnailURL;
@property (strong, nonatomic) UIImage *thumbnailImage;

@end

@implementation FYDBook

- (void)setThumbnailURL:(NSURL*)url
{
    _thumbnailURL = url;
    _thumbnailImage = nil;
}

- (void)setThumbnailImage:(UIImage*)image
{
    _thumbnailImage = image;
    _thumbnailURL = nil;
}

- (void)loadThumbnail:(void(^)(UIImage*,NSError*))completionHandler
{
    if (self.thumbnailImage == nil)
    {
        if (self.thumbnailURL != nil)
        {
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:self.thumbnailURL]
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
             {
                 if (error == nil)
                 {
                     self.thumbnailImage = [UIImage imageWithData:data];
                     completionHandler(self.thumbnailImage, nil);
                 }
                 else
                 {
                     completionHandler(nil, error);
                 }
             }];
        }
        else
        {
            completionHandler(nil, [NSError errorWithDomain:@"com.floyd.keepreading" code:1 userInfo:[NSDictionary dictionaryWithObject:@"FYDBook.loadThumbnail: thumbnailImage == nil && thumbnailURL == nil" forKey:NSLocalizedDescriptionKey]]);
        }
    }
    else
    {
        completionHandler(self.thumbnailImage, nil);
    }
}

@end
