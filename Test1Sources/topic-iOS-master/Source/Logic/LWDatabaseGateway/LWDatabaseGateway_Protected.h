//
//  LWDatabaseGateway_Protected.h
//  topic
//
//  Created by Karen Arzumanian on 7/14/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWDatabaseGateway.h"
#import "FMDB.h"

@interface LWDatabaseGateway ()

- (void)executeDatabaseBlock:(void (^)(FMDatabase *db))block;

@end
