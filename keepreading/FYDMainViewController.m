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

@property (assign, nonatomic) NSRange pageActionSheetRange;
@property (strong, nonatomic) FYDBookReadingDay *pageActionSheetDay;
@property (assign, nonatomic) NSUInteger pageActionSheetCurrentPage;

@property (strong, nonatomic) FYDLibrary *library;

@end

@implementation FYDMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    self.library = [[FYDLibrary alloc] init];
    
    FYDBook *book = [[FYDBook alloc] init];
    book.title = @"Test Book";
    book.firstPage = 10;
    book.lastPage = 100;
    [self.library addReading:book];
    
    [self view]; //force view to load
    self.datePicker.datePickerDelegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setDatePicker:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

- (FYDBookReadingDay*)readingDayForRow:(NSInteger)row
{
    return [[self.library readingsForDate:self.datePicker.currentDate][row] dayForDate:self.datePicker.currentDate];
}

#pragma mark - Date Picker Delegate

- (UIViewController *)datePickerGetViewController:(FYDDatePicker *)datePicker
{
    return self;
}

- (void)datePicker:(FYDDatePicker *)datePicker didPickDate:(NSDate *)date
{
    [self.tableView reloadData];
}

#pragma mark - Prepare For Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"modelToAddBook"])
    {
        FYDAddBookTableViewController *viewController = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        
        viewController.delegate = self;
    }
}

#pragma mark - Add Book Table View Controller Delegate

- (void)addBookTableViewController:(FYDAddBookTableViewController *)tableViewController addBook:(FYDBook *)book
{
    [self.library addReading:book];
    
    [self.tableView reloadData];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showPageActionSheet:[self readingDayForRow:indexPath.row]];
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
    [self.tableView reloadData];
    
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

@end
