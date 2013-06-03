//
//  FYDKeyboardNavigationToolbar.h
//  keepreading
//
//  Created by Florian Kaiser on 03.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import <UIKit/UIKit.h>

@class FYDKeyboardNavigationToolbar;

@protocol FYDKeyboardNavigationToolbarDelegate <NSObject>

- (void)keyboardNavigationToolbarDoneClick:(FYDKeyboardNavigationToolbar*)navigationToolbar;
- (void)keyboardNavigationToolbarPrevClick:(FYDKeyboardNavigationToolbar*)navigationToolbar;
- (void)keyboardNavigationToolbarNextClick:(FYDKeyboardNavigationToolbar*)navigationToolbar;

@end

@interface FYDKeyboardNavigationToolbar : UIToolbar

+ (FYDKeyboardNavigationToolbar*)toolbarWithOwer:(id)owner;

@property (weak, nonatomic) id<FYDKeyboardNavigationToolbarDelegate> navigationDelegate;

@end
