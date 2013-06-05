//
//  FYDBookSearch.h
//  keepreading
//
//  Created by Florian Kaiser on 30.05.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import <Foundation/Foundation.h>

@class FYDBook;
@class FYDBookSearch;

@protocol FYDBookSearchDelegate <NSObject>

@optional
- (BOOL)bookSearch:(FYDBookSearch*)bookSearch shouldParse:(NSUInteger)searchId;

@end

@interface FYDBookSearch : NSObject

- (id)initWithDelegate:(id<FYDBookSearchDelegate>)delegate;

- (NSUInteger)search:(NSString*)searchString completionHandler:(void (^)(NSArray*,NSUInteger,NSError*))handler;

@end
