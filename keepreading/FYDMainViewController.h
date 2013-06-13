//
//  FYDMainViewController.h
//  keepreading
//
//  Created by Florian Kaiser on 07.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FYDAddBookTableViewController.h"
#import "FYDDatePicker.h"

@interface FYDMainViewController : UIViewController<FYDDatePickerDelegate, UITableViewDataSource, UITableViewDelegate, FYDAddBookTableViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@end
