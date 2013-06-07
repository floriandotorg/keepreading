//
//  FYDDatePicker.h
//  keepreading
//
//  Created by Florian Kaiser on 05.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import <UIKit/UIKit.h>

@class FYDDatePicker;

@protocol FYDDatePickerDelegate <NSObject>

- (UIViewController*)datePickerGetViewController:(FYDDatePicker*)datePicker;

@optional
- (void)datePicker:(FYDDatePicker*)datePicker didPickDate:(NSDate*)date;

@end

@interface FYDDatePicker : UIScrollView<UIScrollViewDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSDate *currentDate;
@property (weak, nonatomic) id<FYDDatePickerDelegate> datePickerDelegate;

@end
