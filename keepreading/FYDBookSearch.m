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
    
    NSUInteger searchId = ++self.idCounter;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
        {
            if (![self.delegate respondsToSelector:@selector(bookSearch:shouldParse:)] || [self.delegate bookSearch:self shouldParse:searchId])
            {
                if (!error && data != nil)
                {
                    NSError *err = nil;
                    
                    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
                    dateFormater.dateFormat = @"yyyy-MM-dd";
                    
                    NSDateFormatter *alternativeDateFormater = [[NSDateFormatter alloc] init];
                    alternativeDateFormater.dateFormat = @"yyyy-MM";
                    
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
                                        book.publisher = volumeInfo[@"publisher"];
                                        book.firstPage = 1;
                                        book.lastPage = ((NSNumber*)volumeInfo[@"pageCount"]).unsignedIntegerValue;
                                        book.thumbnailURL = [NSURL URLWithString:volumeInfo[@"imageLinks"][@"thumbnail"]];
                                        
                                        book.publishedDate = [dateFormater dateFromString:volumeInfo[@"publishedDate"]];
                                        
                                        if (book.publishedDate == nil)
                                        {
                                            book.publishedDate = [alternativeDateFormater dateFromString:volumeInfo[@"publishedDate"]];
                                        }
                                        
                                        NSArray *industryIdentifiers = volumeInfo[@"industryIdentifiers"];
                                        
                                        if ([industryIdentifiers isKindOfClass:[NSArray class]])
                                        {
                                            book.isbn = [industryIdentifiers lastObject][@"identifier"];
                                        }
                                        
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
