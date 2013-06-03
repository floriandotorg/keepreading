//
//  FYDAddBookSearchResultsController.h
//  keepreading
//
//  Created by Florian Kaiser on 01.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FYDBookSearch.h"

@class FYDAddBookSearchResultsController;
@class FYDBook;

@protocol FYDAddBookSearchResultsControllerDelegate <NSObject>

- (void)addBookSearchResultsControllerWillBeginSearch:(FYDAddBookSearchResultsController*)searchController;
- (void)addBookSearchResultsControllerWillEndSearch:(FYDAddBookSearchResultsController*)searchController;
- (void)addBookSearchResultsController:(FYDAddBookSearchResultsController*)searchController didFinish:(FYDBook*)book;

@end

@interface FYDAddBookSearchResultsController : NSObject<UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, FYDBookSearchDelegate>

@property (weak, nonatomic) id<FYDAddBookSearchResultsControllerDelegate> delegate;

@end
