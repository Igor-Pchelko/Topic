//
//  LWDatabaseGateway+Topic.h
//  topic
//
//  Created by Karen Arzumanian on 7/14/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWDatabaseGateway.h"

@class LWTopic;

@interface LWDatabaseGateway (Topic)

+ (LWTopic *)topicWithIdentifier:(NSNumber *)identifier;

+ (BOOL)saveTopic:(LWTopic *)topic;
+ (BOOL)removeTopic:(LWTopic *)topic;

+ (void)updateOrInsertTopics:(NSArray *)array;

+ (NSArray *)fetchAllTopics;
+ (NSArray *)notUploadedTopics;

@end
