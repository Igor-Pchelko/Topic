//
//  LWNote.h
//  topic
//
//  Created by Admin on 7/23/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWModel.h"

@interface LWNote : NSObject<LWModel>

@property(nonatomic, strong) NSNumber *identifier;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *description;
@property(nonatomic, strong) NSDate *date;
@property(nonatomic, assign) BOOL added;
@property(nonatomic, strong) NSNumber *topicId;


- (instancetype)initWithIdentifier:(NSNumber *)identifier name:(NSString *)name description:(NSString *)description date:(NSDate *)date topicId:(NSNumber *)topicId;
+ (instancetype)noteWithIdentifier:(NSNumber *)identifier name:(NSString *)name description:(NSString *)description date:(NSDate *)date topicId:(NSNumber *)topicId;

@end
