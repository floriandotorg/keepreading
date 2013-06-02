//
//  FYDAddBookSearchResultsController.m
//  keepreading
//
//  Created by Florian Kaiser on 01.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDAddBookSearchResultsController.h"

#import "FYDBook.h"
#import "FYDBookCell.h"

@interface FYDAddBookSearchResultsController ()

@property (strong, nonatomic) NSArray *books;
@property (strong, nonatomic) FYDBookSearch *bookSearch;
@property (assign, nonatomic) NSUInteger currentSearchId;

@property (weak, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;

@end

@implementation FYDAddBookSearchResultsController

- (id)init
{
    if (self = [super init])
    {
        self.bookSearch = [[FYDBookSearch alloc] initWithDelegate:self];
    }
    return self;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    [tableView registerNib:[UINib nibWithNibName:@"BookCell" bundle:[NSBundle mainBundle]]forCellReuseIdentifier:@"BookCell"];
    [tableView registerNib:[UINib nibWithNibName:@"LoadingCell" bundle:[NSBundle mainBundle]]forCellReuseIdentifier:@"LoadingCell"];
    
    tableView.rowHeight = 121;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.books != nil)
    {
        return self.books.count;
    }
    else
    {
        return 1;
    }
}

- (BOOL)bookSearch:(FYDBookSearch *)bookSearch shouldParse:(NSUInteger)searchId
{
    return searchId == self.currentSearchId;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    self.books = nil;

    self.currentSearchId = [self.bookSearch search:searchBar.text completionHandler:^(NSArray *results, NSUInteger searchId, NSError *error)
     {
         if (!error && searchId == self.currentSearchId)
         {
             self.books = results;
             [self.searchDisplayController.searchResultsTableView reloadData];
         }
         else
         {
             NSLog(@"searchId: %i, error: %@", searchId, error);
         }
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.books != nil)
    {
        FYDBookCell *cell = nil;
        
        if ([tableView respondsToSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:)])
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"BookCell" forIndexPath:indexPath];
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"BookCell"];
        }
        
        FYDBook *book = self.books[indexPath.row];
        
        cell.titleLabel.text = book.title;
        cell.subtitleLabel.text = book.subtitle;
        cell.additionalLabel.text = [NSString stringWithFormat:@"%@\n%i, %@, %i pages", book.author, [[[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:book.publishedDate] year], book.publisher, book.pages];
        cell.thumbnailImageView.image = nil;
        
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:book.thumbnailURL]
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             cell.thumbnailImageView.image = [UIImage imageWithData:data];
         }];
        
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = nil;
        
        if ([tableView respondsToSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:)])
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        }
        
        return cell;
    }
}

@end
