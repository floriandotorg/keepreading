//
//  FYDBook.m
//  keepreading
//
//  Created by Florian Kaiser on 30.05.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDBook.h"

#import <UIImage+ResizeMagick.h>

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
    const CGFloat width = 480;
    
    if (image.size.width > width)
    {
        image = [image resizedImageByWidth:width];
    }
    
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

#pragma mark - Persistent State

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.subtitle forKey:@"subtitle"];
    [aCoder encodeObject:self.author forKey:@"author"];
    [aCoder encodeObject:self.publishedDate forKey:@"publishedDate"];
    [aCoder encodeObject:self.publisher forKey:@"publisher"];
    [aCoder encodeInteger:self.firstPage forKey:@"firstPage"];
    [aCoder encodeInteger:self.lastPage forKey:@"lastPage"];
    [aCoder encodeInteger:self.startPage forKey:@"startPage"];
    [aCoder encodeObject:self.isbn forKey:@"isbn"];
    [aCoder encodeObject:self.thumbnailURL forKey:@"thumbnailURL"];
    [aCoder encodeObject:UIImageJPEGRepresentation(self.thumbnailImage, .9) forKey:@"thumbnailImage"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.subtitle = [aDecoder decodeObjectForKey:@"subtitle"];
        self.author = [aDecoder decodeObjectForKey:@"author"];
        self.publishedDate = [aDecoder decodeObjectForKey:@"publishedDate"];
        self.publisher = [aDecoder decodeObjectForKey:@"publisher"];
        self.firstPage = [aDecoder decodeIntegerForKey:@"firstPage"];
        self.lastPage = [aDecoder decodeIntegerForKey:@"lastPage"];
        self.startPage = [aDecoder decodeIntegerForKey:@"startPage"];
        self.isbn = [aDecoder decodeObjectForKey:@"isbn"];
        
        NSURL *url = [aDecoder decodeObjectForKey:@"thumbnailURL"];
        UIImage *image = [UIImage imageWithData:[aDecoder decodeObjectForKey:@"thumbnailImage"]];
        
        if (image != nil)
        {
            self.thumbnailImage = image;
        }
        else
        {
            self.thumbnailURL = url;
        }
    }
    return self;
}

@end
