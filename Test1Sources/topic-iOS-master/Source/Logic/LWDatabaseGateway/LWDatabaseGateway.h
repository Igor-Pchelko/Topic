//
//  LWDatabaseGateway.h
//  topic
//
//  Created by Lukas K on 04.07.14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

@class FMDatabase;
@class FMDatabaseQueue;

@interface LWDatabaseGateway : NSObject

+ (LWDatabaseGateway *)instance;

@end

#import "LWDatabaseGateway+Category.h"
#import "LWDatabaseGateway+Topic.h"
#import "LWDatabaseGateway+FacebookUser.h"
#import "LWDatabaseGateway+Note.h"
#import "LWDatabaseGateway+FbUser.h"