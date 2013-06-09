//
//  FYDAddBookTableViewController.h
//  keepreading
//
//  Created by Florian Kaiser on 01.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FYDAddBookSearchResultsController.h"
#import "FYDKeyboardNavigationToolbar.h"
#import "FYDAddBookHeaderView.h"
#import "FYDBookSearch.h"

#import "ZBarSDK.h"

@class FYDAddBookTableViewController;

@protocol FYDAddBookTableViewControllerDelegate <NSObject>

- (void)addBookTableViewController:(FYDAddBookTableViewController*)tableViewController addBook:(FYDBook*)book;

@end

@interface FYDAddBookTableViewController : UITableViewController<ZBarReaderDelegate, FYDAddBookSearchResultsControllerDelegate, FYDKeyboardNavigationToolbarDelegate, UITextFieldDelegate, UITableViewDelegate, FYDAddBookHeaderViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, FYDBookSearchDelegate>

@property id<FYDAddBookTableViewControllerDelegate> delegate;

@end
