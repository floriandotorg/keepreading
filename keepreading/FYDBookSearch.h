//
//  FYDBookSearch.h
//  keepreading
//
//  Created by Florian Kaiser on 30.05.13.
//  Copyright (c) 2013 Floyd UG (haftungsbeschränkt). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYDBookSearch : NSObject

+ (void)search:(NSString*)searchString completionHandler:(void (^)(NSArray*,NSError*))handler;

@end
