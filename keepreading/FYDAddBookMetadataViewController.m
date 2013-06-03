//
//  FYDAddBookMetadataViewController.m
//  keepreading
//
//  Created by Florian Kaiser on 03.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDAddBookMetadataViewController.h"

#import "FYDBook.h"

@interface FYDAddBookMetadataViewController ()

@property (weak, nonatomic) IBOutlet UITextField *isbnTextField;
@property (weak, nonatomic) IBOutlet UITextField *publisherTextField;
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;

@property (strong, nonatomic) FYDKeyboardNavigationToolbar *keyboardToolbar;
@property (weak, nonatomic) UITextField *activeTextField;

@end

@implementation FYDAddBookMetadataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.keyboardToolbar = [FYDKeyboardNavigationToolbar toolbarWithOwer:self];
    self.keyboardToolbar.navigationDelegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setIsbnTextField:nil];
    [self setPublisherTextField:nil];
    [self setYearTextField:nil];
    [super viewDidUnload];
}

#pragma mark - Content

- (void)viewWillAppear:(BOOL)animated
{
    self.isbnTextField.text = self.book.isbn;
    self.publisherTextField.text = self.book.publisher;
    
    if (self.book.publishedDate != nil)
    {
        self.yearTextField.text = [NSString stringWithFormat:@"%i", [[[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:self.book.publishedDate] year]];
    }
    else
    {
        self.yearTextField.text = @"";
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.book.isbn = self.isbnTextField.text;
    self.book.publisher = self.publisherTextField.text;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:self.book.publishedDate];
    components.year =  [self.yearTextField.text integerValue];
    self.book.publishedDate = [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Keyboard

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.inputAccessoryView = self.keyboardToolbar;
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)keyboardNavigationToolbarDoneClick:(FYDKeyboardNavigationToolbar *)navigationToolbar
{
    [self.activeTextField resignFirstResponder];
}

- (void)keyboardNavigationToolbarNextClick:(FYDKeyboardNavigationToolbar *)navigationToolbar
{
    if (self.activeTextField == self.isbnTextField)
    {
        [self.publisherTextField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else if (self.activeTextField == self.publisherTextField)
    {
        [self.yearTextField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else
    {
        [self.isbnTextField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)keyboardNavigationToolbarPrevClick:(FYDKeyboardNavigationToolbar *)navigationToolbar
{
    if (self.activeTextField == self.yearTextField)
    {
        [self.publisherTextField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else if (self.activeTextField == self.publisherTextField)
    {
        [self.isbnTextField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else
    {
        [self.isbnTextField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

@end
