//
//  FYDAddWordHeaderView.h
//  keepreading
//
//  Created by Florian Kaiser on 03.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import <UIKit/UIKit.h>

@class FYDAddBookHeaderView;

@protocol FYDAddBookHeaderViewDelegate <NSObject>

- (void)addBookHeaderViewImageButtonClick:(FYDAddBookHeaderView*)view;

@end

@interface FYDAddBookHeaderView : UIView

+ (FYDAddBookHeaderView*)viewWithOwer:(id)owner;

@property (weak, nonatomic) id<FYDAddBookHeaderViewDelegate> addWordDelegate;

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;

@end
