//
//  FYDAddBookSearchResultsController.h
//  keepreading
//
//  Created by Florian Kaiser on 01.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FYDBookSearch.h"

@interface FYDAddBookSearchResultsController : NSObject<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate, FYDBookSearchDelegate>

@end
