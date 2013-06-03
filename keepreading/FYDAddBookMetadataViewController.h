//
//  FYDAddBookMetadataViewController.h
//  keepreading
//
//  Created by Florian Kaiser on 03.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FYDKeyboardNavigationToolbar.h"

@class FYDBook;

@interface FYDAddBookMetadataViewController : UITableViewController<UITextFieldDelegate, UITableViewDelegate, FYDKeyboardNavigationToolbarDelegate>

@property (strong, nonatomic) FYDBook *book;

@end
