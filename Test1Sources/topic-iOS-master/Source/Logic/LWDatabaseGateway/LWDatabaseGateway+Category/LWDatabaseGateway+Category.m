//
//  LWDatabaseGateway+Category.m
//  topic
//
//  Created by Karen Arzumanian on 7/14/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWDatabaseGateway+Category.h"
#import "LWDatabaseGateway_Protected.h"
#import "LWCategory.h"

@implementation LWDatabaseGateway (Category)

+ (LWCategory *)categoryWithIdentifier:(NSNumber *)identifier
{
    __block LWCategory *resultCategory;
    
    [[LWDatabaseGateway instance] executeDatabaseBlock:^(FMDatabase *db)
    {
         if (![db open])
         {
             return;
         }
         
         FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM category WHERE id = ?", identifier];
         
         while ([resultSet next])
         {
             NSString *name = [resultSet stringForColumn:@"name"];
             
             resultCategory = [LWCategory categoryWithIdentifier:identifier name:name];
         }
         
         [db close];
     }];
    
    return resultCategory;
}

+ (void)updateOrInsertCategories:(NSArray *)categories
{
    for (NSDictionary *dictionary in categories)
    {
        LWCategory *category = [LWCategory categoryWithIdentifier:dictionary[@"id"] name:dictionary[@"name"]];
        [self saveCategory:category];
    }
}

+ (BOOL)saveCategory:(LWCategory *)category
{
    __block BOOL successful = NO;
    
    [[LWDatabaseGateway instance] executeDatabaseBlock:^(FMDatabase *db)
    {
        if (![db open])
        {
            successful = NO;
             
            return;
        }
         
        FMResultSet *resultSet = [db executeQuery:@"SELECT id FROM category WHERE id = ?", [category identifier]];
        
        if ([resultSet next])
        {
            successful = [db executeUpdate:@"UPDATE category SET name = ? WHERE id = ?", [category name], [category identifier]];
        }
        else
        {
            successful = [db executeUpdate:@"INSERT INTO category (id, name) VALUES (?,?)", [category identifier], [category name]];
        }
         
        [db close];
    }];
    
    return successful;
}

+ (NSArray *)fetchAllCategories
{
    __block  NSMutableArray *fetchedCategories = [NSMutableArray array];
    
    [[LWDatabaseGateway instance] executeDatabaseBlock:^(FMDatabase *db)
    {
        if (![db open])
        {
            return;
        }
         
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM category"];
         
        while ([resultSet next])
        {
            LWCategory *category = [LWCategory categoryWithIdentifier:@([resultSet intForColumn:@"id"]) name:[resultSet stringForColumn:@"name"]];
            [fetchedCategories addObject:category];
        }
         
        [db close];
    }];
    
    return fetchedCategories;
}

@end
