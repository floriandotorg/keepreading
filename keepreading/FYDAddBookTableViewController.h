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

@interface FYDAddBookTableViewController : UITableViewController<ZBarReaderDelegate, FYDAddBookSearchResultsControllerDelegate, FYDKeyboardNavigationToolbarDelegate, UITextFieldDelegate, UITableViewDelegate, FYDAddBookHeaderViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, FYDBookSearchDelegate>

@end
