//
//  FYDMainViewController.m
//  keepreading
//
//  Created by Florian Kaiser on 07.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDMainViewController.h"

#import "FYDLibrary.h"
#import "FYDBookReading.h"
#import "FYDBookReadingDayCell.h"
#import "FYDDatePicker.h"

@interface FYDMainViewController ()

@property (weak, nonatomic) IBOutlet FYDDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *readLabel;
@property (weak, nonatomic) IBOutlet UILabel *goalLabel;

@property (assign, nonatomic) NSRange pageActionSheetRange;
@property (strong, nonatomic) FYDBookReadingDay *pageActionSheetDay;
@property (assign, nonatomic) NSUInteger pageActionSheetCurrentPage;

@property (strong, nonatomic) NSIndexPath *currentIndexPath;

@property (strong, nonatomic) FYDLibrary *library;

@end

@implementation FYDMainViewController

- (void)awakeFromNib
{
    [self loadLibrary];
    
    if (self.library == nil)
    {
        self.library = [[FYDLibrary alloc] init];
        self.library.goal = 50;
        
        FYDBook *book = [[FYDBook alloc] init];
        book.title = @"Test Book";
        book.firstPage = 10;
        book.lastPage = 100;
        [self.library addReading:book];
    }

    [self view]; //force view to load
    self.datePicker.datePickerDelegate = self;
    
    [self reloadData];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (IBAction)editButtonClick:(UIButton *)sender
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

- (FYDBookReadingDay*)readingDayForRow:(NSInteger)row
{
    return [[self.library readingNo:row ForDate:self.datePicker.currentDate] dayForDate:self.datePicker.currentDate];
}

- (void)reloadData
{
    [self saveLibrary];
    
    [self.tableView reloadData];
    
    NSUInteger goal = self.library.goal;
    NSUInteger pagesRead = [self.library pagesReadAtDate:self.datePicker.currentDate];
    
    self.goalLabel.text = [NSString stringWithFormat:@"%i", goal];
    self.readLabel.text = [NSString stringWithFormat:@"%i", pagesRead];
    
    if (pagesRead < goal)
    {
        self.readLabel.textColor = [UIColor redColor];
        self.readLabel.font = [UIFont boldSystemFontOfSize:17.0];
    }
    else
    {
        self.readLabel.textColor = [UIColor blackColor];
        self.readLabel.font = [UIFont systemFontOfSize:17.0];
    }
}

#pragma mark - Date Picker Delegate

- (UIViewController *)datePickerGetViewController:(FYDDatePicker *)datePicker
{
    return self;
}

- (void)datePicker:(FYDDatePicker *)datePicker didPickDate:(NSDate *)date
{
    [self reloadData];
}

#pragma mark - Prepare For Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"modelToAddBook"])
    {
        FYDAddBookTableViewController *viewController = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        viewController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"modalToDetail"])
    {
        FYDAddBookTableViewController *viewController = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        viewController.delegate = self;
        [viewController editBook:[self readingDayForRow:self.currentIndexPath.row].bookReading.book];
        self.currentIndexPath = nil;
    }
}

#pragma mark - Add Book Table View Controller Delegate

- (void)addBookTableViewController:(FYDAddBookTableViewController *)tableViewController addBook:(FYDBook *)book
{
    [self.library addReading:book];
    [self reloadData];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.library readingsForDate:self.datePicker.currentDate].count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FYDBookReadingDayCell *cell = nil;
    
    if ([tableView respondsToSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:)])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"BookReadingCell" forIndexPath:indexPath];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"BookReadingCell"];
    }
    
    cell.bookReadingDay = [self readingDayForRow:indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showPageActionSheet:[self readingDayForRow:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self.library moveReadingNo:sourceIndexPath.row toNo:destinationIndexPath.row AtDate:self.datePicker.currentDate];
    [self reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        self.currentIndexPath = indexPath;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Book" message:@"This action cannot be undone." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self.library deleteReading:self.currentIndexPath.row AtDate:self.datePicker.currentDate];
        
        [UIView animateWithDuration:0.0 animations:^
         {
             [self.tableView beginUpdates];
             [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
             [self.tableView endUpdates];
         }
         completion:^(BOOL finished)
         {
             [self reloadData];
         }];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    self.currentIndexPath = indexPath;
    [self performSegueWithIdentifier:@"modalToDetail" sender:self];
}

#pragma mark - Page Action Sheet

- (void)showPageActionSheet:(FYDBookReadingDay*)day
{
    self.pageActionSheetDay = day;
    self.pageActionSheetRange = day.pageRange;
    self.pageActionSheetCurrentPage = day.currentPage;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    [pickerView selectRow:self.pageActionSheetCurrentPage - self.pageActionSheetRange.location inComponent:1 animated:NO];
    
    [actionSheet addSubview:pickerView];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Done"]];
    closeButton.momentary = YES;
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
    [actionSheet addSubview:closeButton];
    
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    
    [actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
}

- (void)dismissActionSheet:(UISegmentedControl*)segmentedControl
{
    self.pageActionSheetDay.currentPage = self.pageActionSheetCurrentPage;
    [self reloadData];
    
    [(UIActionSheet*)segmentedControl.superview dismissWithClickedButtonIndex:0 animated:YES];

    self.pageActionSheetDay = nil;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
    {
        return 1;
    }
    else
    {
        return self.pageActionSheetRange.length - self.pageActionSheetRange.location + 1;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
    {
        return @"Page";
    }
    else
    {
        return [NSString stringWithFormat:@"%i", self.pageActionSheetRange.location + row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.pageActionSheetCurrentPage = self.pageActionSheetRange.location + row;
}

#pragma mark - Persistent State

- (NSURL*)applicationDataDirectory
{
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray* possibleURLs = [sharedFM URLsForDirectory:NSApplicationSupportDirectory
                                             inDomains:NSUserDomainMask];
    NSURL* appSupportDir = nil;
    NSURL* appDirectory = nil;
    
    if ([possibleURLs count] >= 1) {
        // Use the first directory (if multiple are returned)
        appSupportDir = [possibleURLs objectAtIndex:0];
    }
    
    // If a valid app support directory exists, add the
    // app's bundle ID to it to specify the final directory.
    if (appSupportDir) {
        NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
        appDirectory = [appSupportDir URLByAppendingPathComponent:appBundleID];
    }
    
    return appDirectory;
}


- (NSString*) pathToLibrary
{
    NSURL *applicationSupportURL = [self applicationDataDirectory];
    
    if (! [[NSFileManager defaultManager] fileExistsAtPath:[applicationSupportURL path]])
    {
        NSError *error = nil;
        
        [[NSFileManager defaultManager] createDirectoryAtPath:[applicationSupportURL path]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        
        if (error)
        {
            NSLog(@"error creating app support dir: %@", error);
        }
    }
    
    NSString *path = [[applicationSupportURL path] stringByAppendingPathComponent:@"library.plist"];
    
    return path;
}

- (void)loadLibrary
{
    self.library = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathToLibrary]];
}

- (void)saveLibrary
{
    [NSKeyedArchiver archiveRootObject:self.library toFile:[self pathToLibrary]];
}

@end
