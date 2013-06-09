//
//  FYDDatePicker.m
//  keepreading
//
//  Created by Florian Kaiser on 05.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDDatePicker.h"

#import "NSDate+dateWithClearedTime.h"
#import "NSDate+dateByAddDays.h"

////////////// Kal

#import "Kal.h"

@interface KalViewController (today)

- (void)today;

@end

@implementation KalViewController (today)

- (void)today
{
    [self showAndSelectDate:[NSDate date]];
}

@end

///////////////

#define FYD_NUM_VISIBLE_LABELS (9.0)

@interface FYDDatePicker ()

@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) CGFloat labelWidth;

@property (strong, nonatomic) NSMutableArray *visibleLabels;
@property (strong, nonatomic) UIView *labelContainerView;
@property (strong, nonatomic) NSMutableDictionary *labelDateMap;

@property (strong, nonatomic) UILabel *weekdayLabel;
@property (strong, nonatomic) UILabel *monthLabel;

@property (strong, nonatomic) UITapGestureRecognizer *doubleTapRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *singleTapRecognizer;

@property (strong, nonatomic) KalViewController *kalViewController;
@property (weak, nonatomic) id<UINavigationControllerDelegate> oldNavigationController;
@property (assign, nonatomic) BOOL navigationBarHidden;

@end

@implementation FYDDatePicker

- (void)awakeFromNib
{
    self.originalFrame = self.frame;
    self.labelWidth = self.originalFrame.size.width / FYD_NUM_VISIBLE_LABELS;
    
    self.contentSize = CGSizeMake(self.labelWidth * FYD_NUM_VISIBLE_LABELS * 10.0, self.frame.size.height);
    CGRect bounds = self.bounds;
    bounds.size.width = self.labelWidth;
    self.bounds = bounds;
    self.clipsToBounds = NO;
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    
    self.labelContainerView = [[UIView alloc] init];
    self.labelContainerView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    self.labelContainerView.userInteractionEnabled = NO;
    
    [self addSubview:self.labelContainerView];
    
    self.doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    self.doubleTapRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:self.doubleTapRecognizer];
    
    self.singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelSingleTap:)];
    self.singleTapRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:self.singleTapRecognizer];
    
    [self.singleTapRecognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];
    
    self.visibleLabels = [[NSMutableArray alloc] init];
    self.labelDateMap = [[NSMutableDictionary alloc] init];
    self.currentDate = [[NSDate date] dateWithClearedTime];
    
    self.weekdayLabel = [[UILabel alloc] init];
    self.weekdayLabel.font = [UIFont boldSystemFontOfSize:11.0];
    self.weekdayLabel.backgroundColor = [UIColor clearColor];
    self.weekdayLabel.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.weekdayLabel];
    
    self.monthLabel = [[UILabel alloc] init];
    self.monthLabel.font = [UIFont boldSystemFontOfSize:11.0];
    self.monthLabel.backgroundColor = [UIColor clearColor];
    self.monthLabel.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.monthLabel];
    
    [self recenter];
    
    self.delegate = self;
}

- (void)setCurrentDate:(NSDate *)currentDate
{
    _currentDate = currentDate;
    
    for (UILabel *label in self.visibleLabels)
    {
        [label removeFromSuperview];
    }
    
    [self.labelDateMap removeAllObjects];
    [self.visibleLabels removeAllObjects];
    
    [self layoutSubviews];
}

- (void)handleDoubleTap:(UITapGestureRecognizer*)sender
{
    self.kalViewController = [[KalViewController alloc] initWithSelectedDate:self.currentDate];
    
    UINavigationController *navigationController = [[self.datePickerDelegate datePickerGetViewController:self] navigationController];
    
    self.oldNavigationController = navigationController.delegate;
    navigationController.delegate = self;
    
    self.navigationBarHidden = navigationController.navigationBarHidden;
    [navigationController setNavigationBarHidden:NO animated:YES];

    [navigationController pushViewController:self.kalViewController animated:YES];
    
    navigationController.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStyleBordered target:self.kalViewController action:@selector(today)];
    
    navigationController.navigationBar.topItem.title = @"Pick Date";
}
                               
- (void)handelSingleTap:(UITapGestureRecognizer*)sender
{
    CGPoint touchPoint = [sender locationInView:self.labelContainerView];
    
    for (UILabel *label in self.visibleLabels)
    {
        if (CGRectContainsPoint(label.frame, touchPoint))
        {
            [self setContentOffset:CGPointMake(CGRectGetMinX(label.frame), 0) animated:YES];
            break;
        }
    }
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIViewController *superViewController = [self.datePickerDelegate datePickerGetViewController:self];
    
    if (viewController == superViewController && self.kalViewController != nil)
    {
        [superViewController.navigationController setNavigationBarHidden:self.navigationBarHidden animated:YES];
        
        navigationController.delegate = self.oldNavigationController;
        self.oldNavigationController = nil;
        
        self.currentDate = self.kalViewController.selectedDate;
        self.kalViewController = nil;
        
        [self callDelegateDidPickDate];
    }
}

- (NSInteger)dayOfDate:(NSDate*)date
{
    return [[[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:date] day];
}

static CGPoint CenterOfRect(CGRect rect)
{
    return CGPointMake(rect.origin.x + (rect.size.width / 2), rect.origin.y + (rect.size.height / 2));
}

- (void)updateCenterLabel
{
    for (UILabel *label in self.visibleLabels)
    {
        label.font = [UIFont systemFontOfSize:label.font.pointSize];
    }
    
    NSUInteger centerLabelIndex = [self.visibleLabels indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
                  {
                      UILabel *label = obj;
                      *stop = NO;
                      
                      if (CGRectContainsPoint(self.frame, CenterOfRect([self.labelContainerView convertRect:label.frame toView:self.superview])))
                      {
                          return YES;
                      }
                      else
                      {
                          return NO;
                      }
                  }];
    
    if (centerLabelIndex != NSNotFound)
    {
        UILabel *centerLabel = self.visibleLabels[centerLabelIndex];

        centerLabel.font = [UIFont boldSystemFontOfSize:centerLabel.font.pointSize];
        
        NSDate *centerDate = self.labelDateMap[[self stringPersonalityOfPointer:centerLabel]];
        
        NSDateFormatter *weekdayFormatter = [[NSDateFormatter alloc] init];
        weekdayFormatter.dateFormat = @"EE";
        self.weekdayLabel.text = [weekdayFormatter stringFromDate:centerDate];
        
        NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
        monthFormatter.dateFormat = @"MMM";
        self.monthLabel.text = [monthFormatter stringFromDate:centerDate];
        
        _currentDate = centerDate;
    }
}

- (void)callDelegateDidPickDate
{
    if ([self.datePickerDelegate respondsToSelector:@selector(datePicker:didPickDate:)])
    {
        [self.datePickerDelegate datePicker:self didPickDate:[self.currentDate dateWithClearedTime]];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self callDelegateDidPickDate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self callDelegateDidPickDate];
    [self recenter];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return CGRectContainsPoint(self.originalFrame, [self convertPoint:point toView:[self superview]]);
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.weekdayLabel.frame = CGRectMake(self.contentOffset.x, 0, self.bounds.size.width, 20);
    self.monthLabel.frame = CGRectMake(self.contentOffset.x, self.bounds.size.height - 20, self.bounds.size.width, 20);
    
    // tile content in visible bounds
    CGRect visibleBounds = [self.superview convertRect:CGRectMake(0, 0, self.originalFrame.size.width, self.originalFrame.size.height) toView:self.labelContainerView];
    CGFloat minimumVisibleX = CGRectGetMinX(visibleBounds) - self.labelWidth;
    CGFloat maximumVisibleX = CGRectGetMaxX(visibleBounds) + self.labelWidth;
    
    [self tileLabelsFromMinX:minimumVisibleX toMaxX:maximumVisibleX];
    
    [self updateCenterLabel];
}

// recenter content periodically to achieve impression of infinite scrolling
- (void)recenter
{
    CGPoint currentOffset = [self contentOffset];
    CGFloat centerOffsetX = self.contentSize.width / 2.0;
    
    self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
    
    // move content by the same amount so it appears to stay still
    for (UILabel *label in self.visibleLabels)
    {
        CGPoint center = [self.labelContainerView convertPoint:label.center toView:self];
        center.x += (centerOffsetX - currentOffset.x);
        label.center = [self convertPoint:center toView:self.labelContainerView];
    }
    
    [self updateCenterLabel];
}

- (NSString*)stringPersonalityOfPointer:(id)obj
{
    return [NSString stringWithFormat:@"%p", obj];
}

- (UILabel *)insertLabel:(NSDate*)date
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.labelWidth, self.bounds.size.height)];
    
    label.text = [NSString stringWithFormat:@"%02i", [self dayOfDate:date]];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    
    [self.labelContainerView addSubview:label];
    
    [self.labelDateMap setObject:date forKey:[self stringPersonalityOfPointer:label]];
    
    return label;
}

- (CGFloat)placeNewLabelOnRight:(CGFloat)rightEdge withDate:(NSDate*)date
{
    UILabel *label = [self insertLabel:date];
    [self.visibleLabels addObject:label]; // add rightmost label at the end of the array
    
    CGRect frame = [label frame];
    frame.origin.x = rightEdge;
    frame.origin.y = [self.labelContainerView bounds].size.height - frame.size.height;
    [label setFrame:frame];
    
    return CGRectGetMaxX(frame);
}

- (CGFloat)placeNewLabelOnLeft:(CGFloat)leftEdge withDate:(NSDate*)date
{
    UILabel *label = [self insertLabel:date];
    [self.visibleLabels insertObject:label atIndex:0]; // add leftmost label at the beginning of the array
    
    CGRect frame = [label frame];
    frame.origin.x = leftEdge - frame.size.width;
    frame.origin.y = [self.labelContainerView bounds].size.height - frame.size.height;
    [label setFrame:frame];
    
    return CGRectGetMinX(frame);
}

- (void)tileLabelsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX
{
    if (self.visibleLabels.count == 0)
    {
        UILabel *label = [self insertLabel:self.currentDate];
        [self.visibleLabels addObject:label];
        
        CGRect frame = [label frame];
        frame.origin.x = [self convertRect:self.bounds toView:self.labelContainerView].origin.x;
        frame.origin.y = [self.labelContainerView bounds].size.height - frame.size.height;
        [label setFrame:frame];
    }
    
    // add labels that are missing on right side
    UILabel *lastLabel = [self.visibleLabels lastObject];
    CGFloat rightEdge = CGRectGetMaxX(lastLabel.frame);
    while (rightEdge < maximumVisibleX)
    {
        rightEdge = [self placeNewLabelOnRight:rightEdge withDate:[[self.labelDateMap objectForKey:[self stringPersonalityOfPointer:[self.visibleLabels lastObject]]] dateByAddDays:1]];
    }

    // add labels that are missing on left side
    UILabel *firstLabel = [self.visibleLabels objectAtIndex:0];
    CGFloat leftEdge = CGRectGetMinX(firstLabel.frame);
    while (leftEdge > minimumVisibleX)
    {
        leftEdge = [self placeNewLabelOnLeft:leftEdge withDate:[[self.labelDateMap objectForKey:[self stringPersonalityOfPointer:[self.visibleLabels objectAtIndex:0]]] dateByAddDays:-1]];
    }

    // remove labels that have fallen off right edge
    lastLabel = [self.visibleLabels lastObject];
    while ([lastLabel frame].origin.x > maximumVisibleX)
    {
        [self.labelDateMap removeObjectForKey:[self stringPersonalityOfPointer:[self.visibleLabels lastObject]]];
        [lastLabel removeFromSuperview];
        [self.visibleLabels removeLastObject];
        lastLabel = [self.visibleLabels lastObject];
    }
    
    // remove labels that have fallen off left edge
    firstLabel = [self.visibleLabels objectAtIndex:0];
    while (CGRectGetMaxX([firstLabel frame]) < minimumVisibleX)
    {
        [self.labelDateMap removeObjectForKey:[self stringPersonalityOfPointer:[self.visibleLabels objectAtIndex:0]]];
        [firstLabel removeFromSuperview];
        [self.visibleLabels removeObjectAtIndex:0];
        firstLabel = [self.visibleLabels objectAtIndex:0];
    }
}

@end
