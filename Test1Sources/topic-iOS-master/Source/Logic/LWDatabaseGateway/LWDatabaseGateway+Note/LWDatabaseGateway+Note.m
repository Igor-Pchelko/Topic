//
//  LWDatabaseGateway+Note.m
//  topic
//
//  Created by Karen Arzumanian on 7/17/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWDatabaseGateway+Note.h"
#import "LWDatabaseGateway_Protected.h"
#import "LWNote.h"
#import "NSDate+ServerGateway.h"

@implementation LWDatabaseGateway (Note)

+ (LWNote *)noteWithIdentifier:(NSNumber *)identifier
{
    __block LWNote *resultNote;
    
    [[LWDatabaseGateway instance] executeDatabaseBlock:^(FMDatabase *db)
    {
        if (![db open])
        {
            return;
        }
         
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM notes WHERE id = ?", identifier];
         
        while ([resultSet next])
        {
            NSString *name = [resultSet stringForColumn:@"name"];
            NSString *description = [resultSet stringForColumn:@"description"];
            NSDate *date = [resultSet dateForColumn:@"date"];
            NSNumber *topicId = @([resultSet intForColumn:@"topicId"]);
            
            resultNote = [LWNote noteWithIdentifier:identifier name:name description:description date:date topicId:topicId];
        }
         
        [db close];
    }];
    
    return resultNote;
}

+ (BOOL)saveNote:(LWNote *)note;
{
    __block BOOL successful = NO;
    
    [[LWDatabaseGateway instance] executeDatabaseBlock:^(FMDatabase *db)
    {
        if (![db open])
        {
            successful = NO;
             
            return;
        }
        
        if ([note identifier] && [[note identifier] integerValue] > 0)
        {
            FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM notes WHERE id = ?", [note identifier]];
            
            if ([resultSet next])
            {
                successful = [db executeUpdate:@"UPDATE notes SET name = ?, description = ?, date = ? WHERE id = ?",
                              [note name], [note description], [note date], [note identifier]];
            }
        }
        
        if (!successful)
        {
            successful = [db executeUpdate:@"INSERT INTO notes (name, topicid, description, date) VALUES (?,?,?,?)", [note name], [note topicId], [note description], [note date]];
            NSLog(@"%@", [db lastError]);
            
            if (successful)
            {
                [note setIdentifier:@([db lastInsertRowId])];
            }
//            else
//            {
//                FMResultSet *resultSet = [db executeQuery:@"SELECT id FROM notes WHERE name = ?", [note name]];
//                
//                if ([resultSet next])
//                {
//                    [note setIdentifier:@([resultSet intForColumn:@"id"])];
//                }
//            }
        }
        
        [db close];
    }];
    
    return successful;
}

+ (NSArray *)notesForTopicID:(NSNumber *)topicID
{
    __block NSMutableArray *resultUsers = [NSMutableArray array];
    
    [[LWDatabaseGateway instance] executeDatabaseBlock:^(FMDatabase *db)
    {
        if (![db open])
        {
            return;
        }
        
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM notes WHERE id IN (SELECT noteID from notesInTopic WHERE topicID = ?)", topicID];
         
        while ([resultSet next])
        {
            NSNumber *identifier = @([resultSet intForColumn:@"id"]);
            NSString *name = [resultSet stringForColumn:@"name"];
            NSString *description = [resultSet stringForColumn:@"description"];
            NSDate *date = [resultSet dateForColumn:@"date"];
            NSNumber *topicId = @([resultSet intForColumn:@"topicId"]);
             
            LWNote *note = [LWNote noteWithIdentifier:identifier name:name description:description date:date topicId:topicId];
             
            [resultUsers addObject:note];
        }
         
        [db close];
    }];
    
    return resultUsers;
}

@end
