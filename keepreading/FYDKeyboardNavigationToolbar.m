//
//  FYDKeyboardNavigationToolbar.m
//  keepreading
//
//  Created by Florian Kaiser on 03.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDKeyboardNavigationToolbar.h"

@implementation FYDKeyboardNavigationToolbar

static UINib *nib = nil;

+ (FYDKeyboardNavigationToolbar*)toolbarWithOwer:(id)owner
{
    if (nib == 0)
    {
        nib = [UINib nibWithNibName:@"KeyboardNavigationToolbar" bundle:[NSBundle mainBundle]];
    }
               
    return [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
}

- (IBAction)doneButtonClick:(UIBarButtonItem *)sender
{
    [self.navigationDelegate keyboardNavigationToolbarDoneClick:self];
}

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex)
    {
        case 0:
            [self.navigationDelegate keyboardNavigationToolbarPrevClick:self];
            break;
            
        case 1:
            [self.navigationDelegate keyboardNavigationToolbarNextClick:self];
            break;
    }
}

@end
