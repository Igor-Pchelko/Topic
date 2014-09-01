//
//  LWDatabaseGateway+FbUser.m
//  topic
//
//  Created by Igor Pchelko on 8/25/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWDatabaseGateway+FacebookUser.h"
#import "LWDatabaseGateway_Protected.h"
#import "LWFbUser.h"

@implementation LWDatabaseGateway (FbUser)

+ (LWFbUser *)fbUserWithFacebookId:(NSString *)facebookId firstName:(NSString*)firstName lastName:(NSString*)lastName
{
    __block LWFbUser *resultUser = NULL;
    
    [[LWDatabaseGateway instance] executeDatabaseBlock:^(FMDatabase *db)
    {
        if (![db open])
        {
            return;
        }
         
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM fbUsers WHERE facebookId = ?", facebookId];

        if ([resultSet next])
        {
            NSNumber *identifier = @([resultSet longLongIntForColumn:@"id"]);
            NSString *facebookId = [resultSet stringForColumn:@"facebookId"];
//            NSString *firstName = [resultSet stringForColumn:@"firstName"];
//            NSString *lastName = [resultSet stringForColumn:@"lastName"];

            resultUser = [LWFbUser userWithIdentifier:identifier facebookId:facebookId firstName:firstName lastName:lastName];
        }
        else
        {
            resultUser = [LWFbUser userWithIdentifier:@0 facebookId:facebookId firstName:firstName lastName:lastName];
        }

        [db close];

        [self saveFbUser:resultUser];
        //        resultUser.facebookId = @"123";
        //        [self saveFbUser:resultUser];
    }];
    
    return resultUser; 
}

+ (BOOL)saveFbUser:(LWFbUser *)fbUser
{
    __block BOOL successful = NO;

    // Interactinf with local database
    [[LWDatabaseGateway instance] executeDatabaseBlock:^(FMDatabase *db)
    {
        if (![db open])
        {
            successful = NO;
             
            return;
        }
        
        if ([fbUser identifier] && [[fbUser identifier] integerValue] > 0)
        {
            FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM fbUsers WHERE id = ?", [fbUser identifier]];
            
            if ([resultSet next])
            {
                successful = [db executeUpdate:@"UPDATE fbUsers SET facebookId = ?, firstName = ?, lastName = ? WHERE id = ?", [fbUser facebookId], [fbUser firstName], [fbUser lastName], [fbUser identifier]];
                NSLog(@"%@", [db lastError]);
            }
        }
        
        if (!successful)
        {
            successful = [db executeUpdate:@"INSERT INTO fbUsers (facebookId, firstName, lastName) VALUES (?,?,?)", [fbUser facebookId], [fbUser firstName], [fbUser lastName]];
            NSLog(@"%@", [db lastError]);
            
            if (successful)
            {
                [fbUser setIdentifier:@([db lastInsertRowId])];
            }
            else
            {
                FMResultSet *resultSet = [db executeQuery:@"SELECT id FROM fbUsers WHERE facebookId = ?", [fbUser facebookId]];
                
                if ([resultSet next])
                {
                    [fbUser setIdentifier:@([resultSet intForColumn:@"id"])];
                }
            }
        }
        
        [db close];
    }];
    
    return successful;
}


@end
