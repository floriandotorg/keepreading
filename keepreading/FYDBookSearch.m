//
//  FYDBookSearch.m
//  keepreading
//
//  Created by Florian Kaiser on 30.05.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDBookSearch.h"

#import "FYDBook.h"

@implementation FYDBookSearch

+ (NSError*)createError:(NSString*)message
{
    return [NSError errorWithDomain:@"com.floyd.keepreading" code:1 userInfo:[NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey]];
}

+ (void)search:(NSString*)searchString completionHandler:(void (^)(NSArray*,NSError*))handler;
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[@"https://www.googleapis.com/books/v1/volumes?q=" stringByAppendingString:searchString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
        {
            NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
            dateFormater.dateFormat = @"yyyy-MM-dd";
            
            if (!error && data != nil)
            {
                NSError *err = nil;
                
                NSDictionary *replyDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0
                                                                   error:&err];
                
                if (!err)
                {
                    if ([replyDictionary isKindOfClass:[NSDictionary class]])
                    {                        
                        NSMutableArray *result = [[NSMutableArray alloc] init];
                        
                        for (NSDictionary *item in replyDictionary[@"items"])
                        {
                            if ([item isKindOfClass:[NSDictionary class]])
                            {
                                NSDictionary *volumeInfo = item[@"volumeInfo"];
                                
                                if ([volumeInfo isKindOfClass:[NSDictionary class]])
                                {
                                    FYDBook *book = [[FYDBook alloc] init];
                                    
                                    book.title = volumeInfo[@"title"];
                                    book.subtitle = volumeInfo[@"subtitle"];
                                    book.author = [((NSArray*)volumeInfo[@"authors"]) componentsJoinedByString:@", "];
                                    book.publishedDate = [dateFormater dateFromString:volumeInfo[@"publishedDate"]];
                                    book.publisher = volumeInfo[@"publisher"];
                                    book.pages = ((NSNumber*)volumeInfo[@"pageCount"]).unsignedIntegerValue;
                                    
                                    NSString *thumbnailURL = volumeInfo[@"imageLinks"][@"thumbnail"];
                                    
                                    if ([thumbnailURL isKindOfClass:[NSString class]])
                                    {
                                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailURL]];
                                        book.thumbnail = [UIImage imageWithData:imageData];
                                    }
                                    else
                                    {
                                        handler(nil, [FYDBookSearch createError:@"parsing error (volumeInfo)"]);
                                        return;
                                    }
                                    
                                    [result addObject:book];
                                }
                                else
                                {
                                    handler(nil, [FYDBookSearch createError:@"parsing error (volumeInfo)"]);
                                    return;
                                }
                            }
                            else
                            {
                                handler(nil, [FYDBookSearch createError:@"parsing error (items)"]);
                                return;
                            }
                        }

                        handler(result, nil);
                        return;
                    }
                    else
                    {
                        handler(nil, [FYDBookSearch createError:@"parsing error"]);
                        return;
                    }
                }
                else
                {
                    handler(nil, err);
                    return;
                }
                
            }
            else
            {
                handler(nil, error);
                return;
            }
        }];
}

@end
