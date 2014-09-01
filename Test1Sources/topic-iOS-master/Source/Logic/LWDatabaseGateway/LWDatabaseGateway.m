//
//  LWDatabaseGateway.m
//  topic
//
//  Created by Lukas K on 04.07.14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

#import "LWDatabaseGateway.h"
#import "LWDatabaseGateway_Protected.h"

static NSString * const databaseName = @"topic.sqlite";

@interface LWDatabaseGateway ()

@property(strong, nonatomic) FMDatabaseQueue *databaseQueue;

@end

@implementation LWDatabaseGateway

+ (LWDatabaseGateway *)instance
{
    static LWDatabaseGateway *_instance = nil;

    @synchronized (self)
    {
        if (_instance == nil)
        {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self setDatabaseQueue:[FMDatabaseQueue databaseQueueWithPath:[LWDatabaseGateway databasePath]]];
        
        [_databaseQueue inDatabase:^(FMDatabase *db)
        {
            if (![db open])
            {
                return;
            }
            
            [self createTablesInDataBase:db];

            [db close];
        }];
    }

    return self;
}

#pragma mark - Protected

- (void)executeDatabaseBlock:(void (^)(FMDatabase *db))block
{
    FMDatabaseQueue *databaseQueue = [FMDatabaseQueue databaseQueueWithPath:[LWDatabaseGateway databasePath]];
    [databaseQueue inDatabase:block];
}

#pragma mark - Private

+ (NSString *)databasePath
{
    NSString *databaseDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [databaseDirectory stringByAppendingPathComponent:databaseName];
}

- (void)createTablesInDataBase:(FMDatabase *)db
{
    NSString *createCategoryTable = @"CREATE TABLE IF NOT EXISTS category( "
                                     "localID INTEGER PRIMARY KEY   AUTOINCREMENT,"
                                     "id INTEGER NOT NULL UNIQUE,"
                                     "name TEXT NOT NULL"
                                     ");";
    
    [db executeUpdate:createCategoryTable];
    
    NSString *createTopicTable = @"CREATE TABLE IF NOT EXISTS topic( "
                                  "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                  "name TEXT NOT NULL,"
                                  "startDate DATE,"
                                  "endDate DATE,"
                                  "creatorImage TEXT,"
                                  "categoryID INTEGER NOT NULL,"
                                  "fbUserID INTEGER NOT NULL,"            
                                  "FOREIGN KEY(categoryID) REFERENCES category(id)"
                                  ");";
    
    [db executeUpdate:createTopicTable];
    
    NSString *createFriendsTable = @"CREATE TABLE IF NOT EXISTS friends( "
    "id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "name TEXT NOT NULL UNIQUE,"
    "avatarURL TEXT"
    ");";
    
    [db executeUpdate:createFriendsTable];
    
    NSString *createFriendsInTopicTable = @"CREATE TABLE IF NOT EXISTS friendsInTopic( "
    "id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "topicID INTEGER NOT NULL REFERENCES topic(id) ON DELETE CASCADE,"
    "friendID INTEGER NOT NULL"
    ");";
    
    [db executeUpdate:createFriendsInTopicTable];
    
    NSString *createNotesTable = @"CREATE TABLE IF NOT EXISTS notes( "
    "id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "topicID INTEGER NOT NULL REFERENCES topic(id) ON DELETE CASCADE,"
    "name TEXT NOT NULL,"
    "description TEXT NOT NULL,"
    "date DATE"
    ");";
    
    [db executeUpdate:createNotesTable];
    
    NSString *createNotesInTopicTable = @"CREATE TABLE IF NOT EXISTS notesInTopic( "
    "id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "topicID INTEGER NOT NULL REFERENCES topic(id) ON DELETE CASCADE,"
    "noteID INTEGER NOT NULL"
    ");";
    
    [db executeUpdate:createNotesInTopicTable];
    
    NSString *createUsersTable = @"CREATE TABLE IF NOT EXISTS fbUsers( "
    "id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "facebookId TEXT NOT NULL UNIQUE,"
    "firstName TEXT,"
    "lastName TEXT"
    ");";
    
    [db executeUpdate:createUsersTable];
}

@end
