//
//  FYDMainViewController.m
//  keepreading
//
//  Created by Florian Kaiser on 07.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDMainViewController.h"

#import "FYDDatePicker.h"

@interface FYDMainViewController ()

@property (weak, nonatomic) IBOutlet FYDDatePicker *datePicker;

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
    [self view]; //force view to load
    
    self.datePicker.datePickerDelegate = self;
    
    self.navigationController.navigationBarHidden = YES;
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

- (void)viewDidUnload {
    [self setDatePicker:nil];
    [super viewDidUnload];
}

- (UIViewController *)datePickerGetViewController:(FYDDatePicker *)datePicker
{
    return self;
}

- (void)datePicker:(FYDDatePicker *)datePicker didPickDate:(NSDate *)date
{
    NSLog(@"%@", date);
}

@end
