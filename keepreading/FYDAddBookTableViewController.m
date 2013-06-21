//
//  FYDAddBookTableViewController.m
//  keepreading
//
//  Created by Florian Kaiser on 01.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDAddBookTableViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "FYDBook.h"
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

@property (assign, nonatomic) NSInteger photoLibraryButtonIndex;
@property (assign, nonatomic) NSInteger cameraButtonIndex;

@property (strong, nonatomic) FYDBook *book;

@end

@implementation FYDAddBookTableViewController

- (void)editBook:(FYDBook*)book
{
    self.book = book;
}

- (void)createHeaderWithSearchBar:(BOOL)searchBarVisible
{
    self.addBookHeaderView = [FYDAddBookHeaderView viewWithOwer:self];
    self.addBookHeaderView.addWordDelegate = self;
    
    if (searchBarVisible == YES)
    {
        UIView *searchBarView = self.tableView.tableHeaderView;
        
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.searchBar.frame.size.width, self.searchBar.frame.size.height + self.addBookHeaderView.frame.size.height)];
        
        [self.tableView.tableHeaderView addSubview:searchBarView];
        self.addBookHeaderView.frame = CGRectOffset(self.addBookHeaderView.frame, 0, self.searchBar.frame.size.height);
        
        [self.tableView.tableHeaderView addSubview:self.addBookHeaderView];
    }
    else
    {
        self.tableView.tableHeaderView = self.addBookHeaderView;
    }
    
    self.addBookHeaderView.backgroundColor = [UIColor clearColor];
    self.addBookHeaderView.titleTextField.delegate = self;
    
    self.addBookHeaderView.imageButton.titleLabel.textAlignment = UITextAlignmentCenter;
}

- (void)addBookHeaderViewImageButtonClick:(FYDAddBookHeaderView *)view
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    self.photoLibraryButtonIndex = NSIntegerMin;
    self.cameraButtonIndex = NSIntegerMin;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        self.photoLibraryButtonIndex = [actionSheet addButtonWithTitle:@"Choose From Library"];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.cameraButtonIndex = [actionSheet addButtonWithTitle:@"Take Photo"];
    }
    
    if (actionSheet.numberOfButtons > 0)
    {
        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
        
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    if (buttonIndex == self.photoLibraryButtonIndex)
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else if (buttonIndex == self.cameraButtonIndex)
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        return;
    }
    
    imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];

    imagePickerController.allowsEditing = YES;
    
    imagePickerController.delegate = self;
    
    [self presentModalViewController:imagePickerController animated:YES];
}

- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    if (info[UIImagePickerControllerEditedImage] != nil)
    {
        UIImage *thumbnail = info[UIImagePickerControllerEditedImage];
        
        [self.book setThumbnailImage:thumbnail];
        [self.addBookHeaderView.imageButton setBackgroundImage:thumbnail forState:UIControlStateNormal];
    }
    else if (info[ZBarReaderControllerResults]  != nil)
    {
        NSMutableArray *symbols = [[NSMutableArray alloc] init];
        
        for (ZBarSymbol *symbol in info[ZBarReaderControllerResults] )
        {
            [symbols addObject:symbol];
        }
        
        [self readBarcode:symbols];
    }
    
    [reader dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.addBookSearchResultsController.delegate = self;
    
    self.keyboardToolbar = [FYDKeyboardNavigationToolbar toolbarWithOwer:self];
    self.keyboardToolbar.navigationDelegate = self;
    
    [self createHeaderWithSearchBar:self.book == nil];
    
    if ([self hasAutoFocus])
    {
        [self createBarcodeButton];
    }
    
    if (self.book == nil)
    {
        self.book = [[FYDBook alloc] init];
    }
    
    // update labels
    [self setBook:self.book];
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

- (IBAction)cancelButtonClick:(UIBarButtonItem *)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveButtonClick:(UIBarButtonItem *)sender
{
    self.book.title = self.addBookHeaderView.titleTextField.text;
    self.book.author = self.authorTextField.text;
    self.book.firstPage = [self.firstPageTextField.text integerValue];
    self.book.lastPage = [self.lastPageTextField.text integerValue];
    
    [self.delegate addBookTableViewController:self addBook:self.book];
    
    [self dismissModalViewControllerAnimated:YES];
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

- (void)setBook:(FYDBook *)book
{
    _book = book;
    
    self.addBookHeaderView.titleTextField.text = book.title;
    
    [book loadThumbnail:^(UIImage *image, NSError *error)
     {
         [self.addBookHeaderView.imageButton setBackgroundImage:image forState:UIControlStateNormal];
         self.addBookHeaderView.imageButton.titleLabel.text = @"";
     }];
    
    self.authorTextField.text = book.author;
    self.firstPageTextField.text = [NSString stringWithFormat:@"%i", book.firstPage];
    self.lastPageTextField.text = [NSString stringWithFormat:@"%i", book.lastPage];
}

- (void)addBookSearchResultsController:(FYDAddBookSearchResultsController *)searchController didFinish:(FYDBook *)book
{
    self.book = book;
}

#pragma mark - Barcode

- (void)barcodeButtonClick:(UIButton*)button
{
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMask(UIInterfaceOrientationPortrait);
    
    reader.showsZBarControls = YES;
    reader.showsHelpOnFail = NO;
    
    [reader.scanner setSymbology:0
                          config:ZBAR_CFG_ENABLE
                              to:0];
    
    [reader.scanner setSymbology:ZBAR_ISBN10
                          config:ZBAR_CFG_ENABLE
                              to:1];
    
    [reader.scanner setSymbology:ZBAR_ISBN13
                          config:ZBAR_CFG_ENABLE
                              to:1];
    
    [reader.scanner setSymbology:ZBAR_EAN13
                          config:ZBAR_CFG_ENABLE
                              to:1];
    
    [self presentModalViewController:reader animated:YES];
}

- (void)search:(FYDBookSearch*)bookSearch byISBN:(NSEnumerator*)enumerator withCompletionHandler:(void(^)(FYDBook*))handler
{
    ZBarSymbol *symbol = enumerator.nextObject;
    
    if (symbol == nil)
    {
        handler(nil);
    }
    else
    {
        [bookSearch search:[NSString stringWithFormat:@"isbn:%@", symbol.data] completionHandler:^(NSArray *results, NSUInteger searchId, NSError *error)
         {
             if (results.count > 0)
             {
                 handler(results[0]);
             }
             else
             {
                 [self search:bookSearch byISBN:enumerator withCompletionHandler:handler];
             }
         }];
    }
}

- (void)readBarcode:(NSArray*)symbols
{    
    [self search:[[FYDBookSearch alloc] initWithDelegate:self] byISBN:symbols.objectEnumerator withCompletionHandler:^(FYDBook *book)
        {
            if (book != nil)
            {
                self.book = book;
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Could not find book." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
                [alert show];
            }
        }];
}

@end
