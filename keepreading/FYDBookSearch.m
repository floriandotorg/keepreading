//
//  FYDBookSearch.m
//  keepreading
//
//  Created by Florian Kaiser on 30.05.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDBookSearch.h"

#import "FYDBook.h"

@interface FYDBookSearch ()

@property (assign, nonatomic) NSUInteger idCounter;
@property (weak, nonatomic) id<FYDBookSearchDelegate> delegate;

@end

@implementation FYDBookSearch

- (id)initWithDelegate:(id<FYDBookSearchDelegate>)delegate
{
    if (self = [super init])
    {
        self.delegate = delegate;
    }
    return self;
}

+ (NSError*)createError:(NSString*)message
{
    return [NSError errorWithDomain:@"com.floyd.keepreading" code:1 userInfo:[NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey]];
}

- (NSUInteger)search:(NSString*)searchString completionHandler:(void (^)(NSArray*,NSUInteger,NSError*))handler
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[@"https://www.googleapis.com/books/v1/volumes?key=AIzaSyAgsavqorzZFulM2iwEIjLKJo09qoD9i8k&q=" stringByAppendingString:searchString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSLog(@"url: %@", request.URL.absoluteString);
    
    NSUInteger searchId = ++self.idCounter;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
        {
            if ([self.delegate bookSearch:self shouldParse:searchId])
            {
                if (!error && data != nil)
                {
                    NSError *err = nil;
                    
                    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
                    dateFormater.dateFormat = @"yyyy-MM-dd";
                    
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
                                        book.thumbnailURL = [NSURL URLWithString:volumeInfo[@"imageLinks"][@"thumbnail"]];
                                        
                                        [result addObject:book];
                                    }
                                    else
                                    {
                                        handler(nil, searchId, [FYDBookSearch createError:@"parsing error (volumeInfo)"]);
                                        return;
                                    }
                                }
                                else
                                {
                                    handler(nil, searchId, [FYDBookSearch createError:@"parsing error (items)"]);
                                    return;
                                }
                            }

                            handler(result, searchId, nil);
                            return;
                        }
                        else
                        {
                            handler(nil, searchId, [FYDBookSearch createError:@"parsing error"]);
                            return;
                        }
                    }
                    else
                    {
                        handler(nil, searchId, err);
                        return;
                    }
                    
                }
                else
                {
                    handler(nil, searchId, error);
                    return;
                }
            }
        }];
    
    return searchId;
}

@end
