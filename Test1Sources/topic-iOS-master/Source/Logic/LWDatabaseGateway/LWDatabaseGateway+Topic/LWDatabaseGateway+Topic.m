//
//  LWDatabaseGateway+Topic.m
//  topic
//
//  Created by Karen Arzumanian on 7/14/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWDatabaseGateway+Topic.h"
#import "LWDatabaseGateway_Protected.h"
#import "LWTopic.h"
#import "LWFacebookUser.h"
#import "LWNote.h"
#import "LWFbUser.h"
#import "LWServerGateway.h"
#import "NSDate+ServerGateway.h"

@implementation LWDatabaseGateway (Topic)

+ (BOOL)saveTopic:(LWTopic *)topic
{
    __block BOOL successful = NO;
    
    [[LWDatabaseGateway instance] executeDatabaseBlock:^(FMDatabase *db)
    {
        if (![db open])
        {
            return;
        }
        
        if (topic.identifier && topic.identifier.integerValue > 0)
        {
            FMResultSet *resultSet = [db executeQuery:@"SELECT id FROM topic WHERE id = ?", topic.identifier];
            
            if ([resultSet next])
            {
                successful = [db executeUpdate:@"UPDATE topic SET name = ?, startDate = ?, endDate = ?, categoryID = ?, creatorImage = ? WHERE id = ?",
                              topic.name, topic.startDate, topic.endDate, [topic categoryIdentifier], [topic creatorImageURLAbsoluteString], topic.identifier];
            }
            
        }
        
        if (!successful)
        {
            successful = [db executeUpdate:@"INSERT INTO topic (id, name, startDate, endDate, categoryID, creatorImage, fbUserID) VALUES (?,?,?,?,?,?,?)",
                          topic.identifier, topic.name, topic.startDate, topic.endDate, [topic categoryIdentifier], [topic creatorImageURLAbsoluteString], topic.fbUserId];
            
            if (successful)
            {
                [topic setIdentifier:@([db lastInsertRowId])];
            }
        }
        
        if (successful)
        {
            for (LWFacebookUser *user in [topic invitedUsers])
            {
                [db close];
                [self saveUser:user];
                if (![db open])
                {
                    return;
                }
                
                FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM friendsInTopic WHERE topicID = ? AND friendID = ?", [topic identifier], [user identifier]];
                
                if (![resultSet next])
                {
                    [db executeUpdate:@"INSERT INTO friendsInTopic (id, topicID, friendID) VALUES (?, ?, ?)", nil, [topic identifier], [user identifier]];
                    NSLog(@"%@", [db lastError]);
                }
            }
            
            for (LWNote *note in [topic notes])
            {
                [db close];
                note.topicId = [[topic identifier] copy];
                [self saveNote:note];
                if (![db open])
                {
                    return;
                }
                
                FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM notesInTopic WHERE topicID = ? AND noteID = ?", [topic identifier], [note identifier]];
                
                if (![resultSet next])
                {
                    [db executeUpdate:@"INSERT INTO notesInTopic (id, topicID, noteID) VALUES (?, ?, ?)", nil, [topic identifier], [note identifier]];
                }
            }
        }
        
        [db close];
        
    }];
    
    return successful;
}

+ (BOOL)removeTopic:(LWTopic *)topic
{
    __block BOOL successful = NO;
    
    [[LWDatabaseGateway instance] executeDatabaseBlock:^(FMDatabase *db)
    {
        if (![db open])
        {
            return;
        }
        
        sqlite3_exec([db sqliteHandle], "PRAGMA foreign_keys = ON;", 0, 0, 0);
         
        if ([topic identifier] && [[topic identifier] integerValue] > 0)
        {
            successful = [db executeUpdate:@"DELETE FROM topic WHERE id = ?", [topic identifier]];
        }
         
        [db close];
         
    }];
    
    return successful;
}


+ (void)updateOrInsertTopics:(NSArray *)array
{
    // Check if all that topics in local DB if no just remove them
    NSArray *allTopics = [self fetchAllTopics];

    for (LWTopic *topic in allTopics)
    {
        bool found = false;
        
        for (NSDictionary *dictRemote in array)
        {
            NSNumber *idRemote = dictRemote[@"id"];
            
            if ([topic.identifier compare:idRemote] == NSOrderedSame)
            {
                found = true;
                break;
            }
        }
        
        [self removeTopic:topic];
    }
    
    
    for (NSDictionary *dictionary in array)
    {
        NSNumber *identifier = dictionary[@"id"];
        NSString *name = dictionary[@"name"];
        NSDate *startDate = [NSDate dateFromAPITimeString:dictionary[@"startdate"]];
        NSDate *endDate = [NSDate dateFromAPITimeString:dictionary[@"enddate"]];
        NSNumber *fbUserId = dictionary[@"fbUserId"];
        id urlString = dictionary[@"creatorimage"];
        
        NSURL *creatorImageURL;
        
        if (urlString && [urlString isKindOfClass:[NSString class]])
        {
            creatorImageURL = [NSURL URLWithString:urlString];
        }
        
        LWCategory *category = [self categoryWithIdentifier:dictionary[@"category"]];
        
        id friends = dictionary[@"friends"];
        NSMutableArray *invitedUsers = [NSMutableArray array];
        
        if ([friends isKindOfClass:[NSArray class]])
        {
            for (NSDictionary *friend in friends)
            {
                LWFacebookUser *user = [LWFacebookUser userWithIdentifier:nil
                                                                     name:friend[@"name"]
                                                          avatarURLString:friend[@"avatarURL"]];
                [invitedUsers addObject:user];
            }
        }
        
        id notes = dictionary[@"notes"];
        NSMutableArray *notesInTopic = [NSMutableArray array];
        
        if ([notes isKindOfClass:[NSArray class]])
        {
            for (NSDictionary *noteDictionarry in notes)
            {
                NSDate *d = [NSDate dateFromAPITimeString:noteDictionarry[@"date"]];
                
                LWNote *note = [LWNote noteWithIdentifier:nil
                                                     name:noteDictionarry[@"name"]
                                              description:noteDictionarry[@"description"]
                                                     date:d
                                                  topicId:noteDictionarry[@"topicId"]];

                [notesInTopic addObject:note];
            }
        }
        
        LWTopic *topic = [[LWTopic alloc] initWithIdentifier:identifier
                                                    fbUserId:fbUserId
                                                        name:name
                                                    category:category
                                                   startDate:startDate
                                                     endDate:endDate
                                             creatorImageURL:creatorImageURL
                                                invitedUsers:invitedUsers
                                                       notes:notesInTopic];
        [self saveTopic:topic];
    }
}


+ (LWTopic *)topicWithIdentifier:(NSNumber *)identifier
{
    __block  LWTopic *resultTopic = nil;
    
    [[LWDatabaseGateway instance] executeDatabaseBlock:^(FMDatabase *db)
    {
        if (![db open])
        {
            return;
        }
        
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM topic WHERE id = ?", identifier];
        
        while ([resultSet next])
        {
            
            NSString *name = [resultSet stringForColumn:@"name"];
            NSDate *startDate = [resultSet dateForColumn:@"startDate"];
            NSDate *endDate = [resultSet dateForColumn:@"endDate"];
            NSURL *creatorImageURL = [NSURL URLWithString:[resultSet stringForColumn:@"creatorImage"]];
            LWCategory *category = [self categoryWithIdentifier:@([resultSet intForColumn:@"categoryID"])];
            NSArray *invitedUsers = [self usersForTopicID:identifier];
            NSArray *notes = [self notesForTopicID:identifier];
            NSNumber *fbUserId = [resultSet objectForColumnName:@"fbUserId"];
            
            resultTopic = [[LWTopic alloc] initWithIdentifier:identifier
                                                     fbUserId:fbUserId
                                                         name:name
                                                     category:category
                                                    startDate:startDate
                                                      endDate:endDate
                                              creatorImageURL:creatorImageURL
                                                 invitedUsers:invitedUsers
                                                        notes:notes];
        }
        
        [db close];
    }];
    
    
//    CREATE TABLE topic( id INTEGER PRIMARY KEY AUTOINCREMENT,
//                       name TEXT NOT NULL,
//                       startDate DATE,
//                       endDate DATE,
//                       creatorImage TEXT,
//                       categoryID INTEGER NOT NULL,
//                       FOREIGN KEY(categoryID) REFERENCES category(id));
//    
//    INSERT INTO "topic" VALUES(1,'Topic1',
//                               1408957711,
//                               1408957714,
//                               'https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xaf1/v/t1.0-1/c39.39.490.490/s50x50/580204_4894300162900_1618980402_n.jpg?oh=f781f63f78149717d30e08dc265704cd&oe=545E53DD&__gda__=1416202081_7e71f756741e904748ef9d59abb50283',
//                               7);
    
    
    return resultTopic;
}

+ (NSArray *)fetchAllTopics
{
    __block  NSMutableArray *fetchedTopics = [NSMutableArray array];
    
    // fbUser have to be setted
    if ([LWServerGateway instance].fbUser != nil)
    {
        [[LWDatabaseGateway instance] executeDatabaseBlock:^(FMDatabase *db)
         {
             if (![db open])
             {
                 return;
             }
             
             FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM topic WHERE fbUserId = ?", [LWServerGateway instance].fbUser.identifier];
             
             while ([resultSet next])
             {
                 NSNumber *identifier = @([resultSet intForColumn:@"id"]);
                 NSString *name = [resultSet stringForColumn:@"name"];
                 NSDate *startDate = [resultSet dateForColumn:@"startDate"];
                 NSDate *endDate = [resultSet dateForColumn:@"endDate"];
                 NSURL *creatorImageURL = [NSURL URLWithString:[resultSet stringForColumn:@"creatorImage"]];
                 LWCategory *category = [self categoryWithIdentifier:@([resultSet intForColumn:@"categoryID"])];
                 NSArray *invitedUsers = [self usersForTopicID:identifier];
                 NSArray *notes = [self notesForTopicID:identifier];
                 NSNumber *fbUserId = [resultSet objectForColumnName:@"fbUserId"];
                 
                 LWTopic *topic = [[LWTopic alloc] initWithIdentifier:identifier
                                                             fbUserId:fbUserId
                                                                 name:name
                                                             category:category
                                                            startDate:startDate
                                                              endDate:endDate
                                                      creatorImageURL:creatorImageURL
                                                         invitedUsers:invitedUsers
                                                                notes:notes];
                 [fetchedTopics addObject:topic];
             }
             
             [db close];
         }];
    }
    
    
    return fetchedTopics;
}

+ (NSArray *)notUploadedTopics
{
    __block  NSMutableArray *fetchedTopics = [NSMutableArray array];
    
    [[LWDatabaseGateway instance] executeDatabaseBlock:^(FMDatabase *db)
    {
        if (![db open])
        {
            return;
        }

        
        // TODO: ID should be remote ID and fetched from server side
        
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM topic WHERE id=NULL OR id = 0"];
        
        while ([resultSet next])
        {
            NSNumber *identifier = @([resultSet intForColumn:@"id"]);
            NSString *name = [resultSet stringForColumn:@"name"];
            NSDate *startDate = [resultSet dateForColumn:@"startDate"];
            NSDate *endDate = [resultSet dateForColumn:@"endDate"];
            NSURL *creatorImageURL = [NSURL URLWithString:[resultSet stringForColumn:@"creatorImage"]];
            LWCategory *category = [self categoryWithIdentifier:@([resultSet intForColumn:@"categoryID"])];
            NSArray *invitedUsers = [self usersForTopicID:identifier];
            NSArray *notes = [self notesForTopicID:identifier];
            NSNumber *fbUserId = [resultSet objectForColumnName:@"fbUserId"];

            LWTopic *topic = [[LWTopic alloc] initWithIdentifier:identifier
                                                        fbUserId:fbUserId
                                                            name:name
                                                        category:category
                                                       startDate:startDate
                                                         endDate:endDate
                                                 creatorImageURL:creatorImageURL
                                                    invitedUsers:invitedUsers
                                                           notes:notes];
            [fetchedTopics addObject:topic];
        }
        
        [db close];
    }];
    
    return fetchedTopics;
}

@end
