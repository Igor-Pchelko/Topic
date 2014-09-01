//
//  LWDatabaseGateway+FacebookUser.m
//  topic
//
//  Created by Karen Arzumanian on 7/17/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWDatabaseGateway+FacebookUser.h"
#import "LWDatabaseGateway_Protected.h"
#import "LWFacebookUser.h"

@implementation LWDatabaseGateway (FacebookUser)

+ (LWFacebookUser *)userWithIdentifier:(NSNumber *)identifier
{
    __block LWFacebookUser *resultUser;
    
    [[LWDatabaseGateway instance] executeDatabaseBlock:^(FMDatabase *db)
    {
        if (![db open])
        {
            return;
        }
         
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM friends WHERE id = ?", identifier];
         
        while ([resultSet next])
        {
            NSString *name = [resultSet stringForColumn:@"name"];
            NSString *avatarURL = [resultSet stringForColumn:@"avatarURL"];
             
            resultUser = [LWFacebookUser userWithIdentifier:identifier name:name avatarURLString:avatarURL];
        }
         
        [db close];
    }];
    
    return resultUser;
}

+ (BOOL)saveUser:(LWFacebookUser *)user
{
    __block BOOL successful = NO;
    
    [[LWDatabaseGateway instance] executeDatabaseBlock:^(FMDatabase *db)
    {
        if (![db open])
        {
            successful = NO;
             
            return;
        }
        
        if ([user identifier] && [[user identifier] integerValue] > 0)
        {
            FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM friends WHERE id = ?", [user identifier]];
            
            if ([resultSet next])
            {
                successful = [db executeUpdate:@"UPDATE friends SET name = ?, avatarURL = ? WHERE id = ?", [user name], [user avatarURLString], [user identifier]];
                NSLog(@"%@", [db lastError]);
            }
        }
        
        if (!successful)
        {
            successful = [db executeUpdate:@"INSERT INTO friends (id, name, avatarURL) VALUES (?,?,?)", [user identifier], [user name], [user avatarURLString]];
            NSLog(@"%@", [db lastError]);
            
            if (successful)
            {
                [user setIdentifier:@([db lastInsertRowId])];
            }
            else
            {
                FMResultSet *resultSet = [db executeQuery:@"SELECT id FROM friends WHERE name = ?", [user name]];
                
                if ([resultSet next])
                {
                    [user setIdentifier:@([resultSet intForColumn:@"id"])];
                }
            }
        }
        
        [db close];
    }];
    
    return successful;
}

+ (NSArray *)usersForTopicID:(NSNumber *)topicID
{
    __block NSMutableArray *resultUsers = [NSMutableArray array];
    
    [[LWDatabaseGateway instance] executeDatabaseBlock:^(FMDatabase *db)
    {
        if (![db open])
        {
            return;
        }
        
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM friends WHERE id IN (SELECT friendID from friendsInTopic WHERE topicID = ?)", topicID];
         
        while ([resultSet next])
        {
            NSNumber *identifier = @([resultSet intForColumn:@"id"]);
            NSString *name = [resultSet stringForColumn:@"name"];
            NSString *avatarURL = [resultSet stringForColumn:@"avatarURL"];
             
            LWFacebookUser *user = [LWFacebookUser userWithIdentifier:identifier name:name avatarURLString:avatarURL];
             
            [resultUsers addObject:user];
        }
         
        [db close];
    }];
    
    return resultUsers;
}

@end
