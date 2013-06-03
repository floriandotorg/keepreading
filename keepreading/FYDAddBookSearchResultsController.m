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

#pragma mark - Book Search Delegate

- (BOOL)bookSearch:(FYDBookSearch *)bookSearch shouldParse:(NSUInteger)searchId
{
    return searchId == self.currentSearchId;
}

#pragma mark - Search Display Controller Delegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self.delegate addBookSearchResultsControllerWillBeginSearch:self];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self.delegate addBookSearchResultsControllerWillEndSearch:self];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    [tableView registerNib:[UINib nibWithNibName:@"BookCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"BookCell"];
    [tableView registerNib:[UINib nibWithNibName:@"LoadingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"LoadingCell"];
    
    tableView.rowHeight = 121;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    self.books = nil;

    self.currentSearchId = [self.bookSearch search:searchString completionHandler:^(NSArray *results, NSUInteger searchId, NSError *error)
     {
         if (!error)
         {
             self.books = results;
             [controller.searchResultsTableView reloadData];
         }
         else
         {
             NSLog(@"searchId: %i, error: %@", searchId, error);
         }
         
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     }];
    
    return YES;
}

#pragma mark - Table View Data Source

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
        cell.additionalLabel.text = [NSString stringWithFormat:@"%@\n%i, %@, %i pages", book.author, [[[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:book.publishedDate] year], book.publisher, book.lastPage];
        cell.thumbnailImageView.image = nil;
        
        [book loadThumbnail:^(UIImage *image, NSError *error)
            {
                cell.thumbnailImageView.image = image;
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

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.books != nil)
    {
        [self.delegate addBookSearchResultsController:self didFinish:self.books[indexPath.row]];
        [self.searchDisplayController setActive:NO animated:YES];
    }
}

@end
