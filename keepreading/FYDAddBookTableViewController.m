//
//  FYDAddBookTableViewController.m
//  keepreading
//
//  Created by Florian Kaiser on 01.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDAddBookTableViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "FYDBook.h"
#import "FYDAddBookHeaderView.h"
#import "FYDAddBookMetadataViewController.h"

@class FYDAddBookSearchResultsController;

@interface FYDAddBookTableViewController ()

@property (strong, nonatomic) IBOutlet FYDAddBookSearchResultsController *addBookSearchResultsController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) UITextField *searchTextField;

@property (weak, nonatomic) FYDAddBookHeaderView *addBookHeaderView;

@property (weak, nonatomic) IBOutlet UITextField *authorTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstPageTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastPageTextField;

@property (strong, nonatomic) FYDKeyboardNavigationToolbar *keyboardToolbar;
@property (weak, nonatomic) UITextField *activeTextField;

@property (strong, nonatomic) FYDBook *book;

@end

@implementation FYDAddBookTableViewController

- (void)createHeader
{
    self.addBookHeaderView = [FYDAddBookHeaderView viewWithOwer:self];
    
    UIView *searchBarView = self.tableView.tableHeaderView;
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.searchBar.frame.size.width, self.searchBar.frame.size.height + self.addBookHeaderView.frame.size.height)];
    
    [self.tableView.tableHeaderView addSubview:searchBarView];
    [self.tableView.tableHeaderView addSubview:self.addBookHeaderView];
    
    self.addBookHeaderView.frame = CGRectOffset(self.addBookHeaderView.frame, 0, self.searchBar.frame.size.height);
    
    self.addBookHeaderView.backgroundColor = [UIColor clearColor];
    self.addBookHeaderView.titleTextField.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.addBookSearchResultsController.delegate = self;
    
    self.keyboardToolbar = [FYDKeyboardNavigationToolbar toolbarWithOwer:self];
    self.keyboardToolbar.navigationDelegate = self;
    
    [self createHeader];
    
    if ([self hasAutoFocus])
    {
        [self createBarcodeButton];
    }
}

- (void)viewDidUnload
{
    [self setAddBookSearchResultsController:nil];
    [self setSearchBar:nil];
    [self setAuthorTextField:nil];
    [self setFirstPageTextField:nil];
    [self setLastPageTextField:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createBarcodeButton
{
    for (UIView *subview in self.searchBar.subviews)
    {
        if ([subview conformsToProtocol:@protocol(UITextInputTraits)])
        {
            self.searchTextField = (UITextField*)subview;
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 31)];
            [button setImage:[UIImage imageNamed:@"barcode_button.png"] forState:UIControlStateNormal];
            button.imageEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 0);
            [button addTarget:self action:@selector(barcodeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            self.searchTextField.rightView = button;
            self.searchTextField.rightViewMode = UITextFieldViewModeAlways;
        }
    }
}

- (BOOL)hasAutoFocus
{
    return [[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] isFocusModeSupported:AVCaptureFocusModeAutoFocus];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"MetadataCell"])
    {
        return indexPath;
    }
    else
    {
        return nil;
    }
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

- (IBAction)handleTap:(UITapGestureRecognizer *)sender
{
    [self.activeTextField resignFirstResponder];
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
    if (self.activeTextField == self.addBookHeaderView.titleTextField)
    {
        [self.authorTextField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else if (self.activeTextField == self.authorTextField)
    {
        [self.firstPageTextField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else if (self.activeTextField == self.firstPageTextField)
    {
        [self.lastPageTextField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else
    {
        [self.addBookHeaderView.titleTextField becomeFirstResponder];
        [self.tableView scrollRectToVisible:self.addBookHeaderView.titleTextField.frame animated:YES];
    }
}

- (void)keyboardNavigationToolbarPrevClick:(FYDKeyboardNavigationToolbar *)navigationToolbar
{
    if (self.activeTextField == self.lastPageTextField)
    {
        [self.firstPageTextField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else if (self.activeTextField == self.firstPageTextField)
    {
        [self.authorTextField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else if (self.activeTextField == self.authorTextField)
    {
        [self.addBookHeaderView.titleTextField becomeFirstResponder];
        [self.tableView scrollRectToVisible:self.addBookHeaderView.titleTextField.frame animated:YES];
    }
    else
    {
        [self.lastPageTextField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - Prepare For Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushToMetadata"])
    {
        [segue.destinationViewController setBook:self.book];
    }
}

#pragma mark - Add Book Search Results Controller Delegate

- (void)addBookSearchResultsControllerWillBeginSearch:(FYDAddBookSearchResultsController *)searchController
{
    self.searchTextField.rightViewMode = UITextFieldViewModeNever;
}

- (void)addBookSearchResultsControllerWillEndSearch:(FYDAddBookSearchResultsController *)searchController
{
    self.searchTextField.rightViewMode = UITextFieldViewModeAlways;
}

- (void)addBookSearchResultsController:(FYDAddBookSearchResultsController *)searchController didFinish:(FYDBook *)book
{
    self.book = book;
    
    self.addBookHeaderView.titleTextField.text = book.title;
    
    [book loadThumbnail:^(UIImage *image, NSError *error)
        {
            [self.addBookHeaderView.imageButton setBackgroundImage:image forState:UIControlStateNormal];
        }];
        
    self.authorTextField.text = book.author;
    self.firstPageTextField.text = [NSString stringWithFormat:@"%i", book.firstPage];
    self.lastPageTextField.text = [NSString stringWithFormat:@"%i", book.lastPage];
}

#pragma mark - Barcode

- (void)barcodeButtonClick:(UIButton*)button
{
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMask(UIInterfaceOrientationPortrait);
    
    reader.showsZBarControls = NO;
    reader.showsHelpOnFail = NO;
    
    [reader.scanner setSymbology:0
                          config:ZBAR_CFG_ENABLE
                              to:0];
    
    [reader.scanner setSymbology:ZBAR_ISBN13
                          config:ZBAR_CFG_ENABLE
                              to:1];
    
    [self presentModalViewController:reader animated:YES];
}

- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    ZBarSymbol *symbol = nil;
    
    for (symbol in info[ZBarReaderControllerResults])
    {
        break;
    }
    
    NSLog(@"%@", symbol.data);
    
    [reader dismissModalViewControllerAnimated:YES];
}

@end
