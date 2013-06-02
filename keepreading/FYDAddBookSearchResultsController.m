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
#import "FYDBookSearch.h"

@interface FYDAddBookSearchResultsController ()

@property (strong, nonatomic) NSArray *books;

@property (weak, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;

@end

@implementation FYDAddBookSearchResultsController

- (void)awakeFromNib
{
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"BookCell" bundle:[NSBundle mainBundle]]forCellReuseIdentifier:@"BookCell"];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"LoadingCell" bundle:[NSBundle mainBundle]]forCellReuseIdentifier:@"LoadingCell"];
    
    self.searchDisplayController.searchResultsTableView.rowHeight = 121;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.books.count > 0)
    {
        return self.books.count;
    }
    else
    {
        return 1;
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [FYDBookSearch search:searchBar.text completionHandler:^(NSArray *results, NSError *error)
     {
         if (!error)
         {
             self.books = results;
             [self.searchDisplayController.searchResultsTableView reloadData];
         }
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.books.count > 0)
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
        cell.thumbnailImageView.image = book.thumbnail;
        
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
