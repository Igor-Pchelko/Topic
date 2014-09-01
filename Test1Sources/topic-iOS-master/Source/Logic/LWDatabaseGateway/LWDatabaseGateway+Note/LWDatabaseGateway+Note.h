//
//  LWDatabaseGateway+Note.h
//  topic
//
//  Created by Karen Arzumanian on 7/17/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWDatabaseGateway.h"

@class LWNote;

@interface LWDatabaseGateway (Note)

+ (LWNote *)noteWithIdentifier:(NSNumber *)identifier;
+ (BOOL)saveNote:(LWNote *)note;
+ (NSArray *)notesForTopicID:(NSNumber *)topicID;

@end
