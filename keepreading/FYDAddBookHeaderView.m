//
//  FYDAddWordHeaderView.m
//  keepreading
//
//  Created by Florian Kaiser on 03.06.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDAddBookHeaderView.h"

@implementation FYDAddBookHeaderView

static UINib *nib = nil;

+ (FYDAddBookHeaderView*)viewWithOwer:(id)owner
{
    if (nib == 0)
    {
        nib = [UINib nibWithNibName:@"AddWordHeaderView" bundle:[NSBundle mainBundle]];
    }
    
    return [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
}

- (IBAction)imageButtonClick:(UIButton *)sender
{
    [self.addWordDelegate addBookHeaderViewImageButtonClick:self];
}

@end
