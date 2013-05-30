//
//  FYDLibrary.m
//  keepreading
//
//  Created by Florian Kaiser on 30.05.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import "FYDLibrary.h"

#import "FYDBook.h"

@interface FYDLibrary ()

@property (strong, nonatomic) NSMutableArray *bookArray;
@property (strong, nonatomic) NSDictionary *readDictionary;

@end

@implementation FYDLibrary

- (id)init
{
    if (self = [super init])
    {
        self.bookArray = [[NSMutableArray alloc] init];
        self.readDictionary = [[NSDictionary alloc] init];
    }
    
    return self;
}

- (void)addBook:(FYDBook*)book
{
    [self.bookArray addObject:book];
}

@end
