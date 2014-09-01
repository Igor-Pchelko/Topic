//
//  LWDatabaseGateway+FacebookUser.h
//  topic
//
//  Created by Karen Arzumanian on 7/17/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWDatabaseGateway.h"

@class LWFacebookUser;

@interface LWDatabaseGateway (FacebookUser)

+ (LWFacebookUser *)userWithIdentifier:(NSNumber *)identifier;
+ (BOOL)saveUser:(LWFacebookUser *)user;
+ (NSArray *)usersForTopicID:(NSNumber *)topicID;

@end
