//
//  LWDatabaseGateway+Category.h
//  topic
//
//  Created by Karen Arzumanian on 7/14/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWDatabaseGateway.h"

@class LWCategory;

@interface LWDatabaseGateway (Category)

+ (LWCategory *)categoryWithIdentifier:(NSNumber *)identifier;
+ (void)updateOrInsertCategories:(NSArray *)categories;
+ (NSArray *)fetchAllCategories;
+ (BOOL)saveCategory:(LWCategory *)category;

@end

