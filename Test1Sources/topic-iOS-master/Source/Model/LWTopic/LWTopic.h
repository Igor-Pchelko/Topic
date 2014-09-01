//
//  LWTopic.h
//  topic
//
//  Created by Lukas K on 04.07.14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

#import "LWModel.h"

@class LWCategory;

@interface LWTopic : NSObject<LWModel>

@property(nonatomic, strong) NSNumber *fbUserId; // facebook user id, => LWFbUser.identifier
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSArray *invitedUsers; // |NSArray| of |LWFacebookUser|
@property(nonatomic, copy) NSArray *notes; // |NSArray| of |LWNote|
@property(nonatomic, strong) NSNumber *identifier;
@property(nonatomic, strong) LWCategory *category;
@property(nonatomic, strong) NSDate *startDate;
@property(nonatomic, strong) NSDate *endDate;
@property(nonatomic, strong) NSURL *creatorImageURL;
@property(nonatomic, readonly) NSNumber *categoryIdentifier;
@property(nonatomic, readonly) NSString *creatorImageURLAbsoluteString;

- (instancetype)initWithIdentifier:(NSNumber *)identifier
                          fbUserId:(NSNumber *)fbUserId
                              name:(NSString *)name
                          category:(LWCategory *)category
                         startDate:(NSDate *)startDate
                           endDate:(NSDate *)endDate
                   creatorImageURL:(NSURL *)creatorImageURL
                      invitedUsers:(NSArray *)invitedUsers
                             notes:(NSArray *)notes;

- (NSInteger)percentage;
- (NSString *)percentageString;

@end
