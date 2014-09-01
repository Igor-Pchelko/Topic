//
//  LWTopic.m
//  topic
//
//  Created by Lukas K on 04.07.14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

#import "LWFbUser.h"
#import "LWTopic.h"
#import "LWCategory.h"
#import "LWNote.h"
#import "LWFacebookUser.h"
#import "NSDate+ServerGateway.h"

@implementation LWTopic

- (instancetype)initWithIdentifier:(NSNumber *)identifier
                          fbUserId:(NSNumber *)fbUserId
                              name:(NSString *)name
                          category:(LWCategory *)category
                         startDate:(NSDate *)startDate
                           endDate:(NSDate *)endDate
                   creatorImageURL:(NSURL *)creatorImageURL
                      invitedUsers:(NSArray *)invitedUsers
                             notes:(NSArray *)notes
{
    self = [super init];
    
    if (self)
    {
        [self setIdentifier:identifier];
        [self setFbUserId:fbUserId];
        [self setName:name];
        [self setCategory:category];
        [self setStartDate:startDate];
        [self setEndDate:endDate];
        [self setCreatorImageURL:creatorImageURL];
        [self setInvitedUsers:invitedUsers];
        [self setNotes:notes];
    }
    
    return self;
}

- (NSNumber *)categoryIdentifier
{
    return [_category identifier];
}

- (NSString *)creatorImageURLAbsoluteString
{
    return [_creatorImageURL absoluteString];
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:5];
    
    if (_name)
    {
        result[@"name"] = _name;
    }
    
    NSString *startDate = [NSDate apiStringFromDate:_startDate];
    
    if (startDate)
    {
        result[@"startdate"] = startDate;
    }
    
    NSString *endDate = [NSDate apiStringFromDate:_endDate];
    
    if (endDate)
    {
        result[@"enddate"] = endDate;
    }
    
    if ([self categoryIdentifier])
    {
        result[@"category"] = [self categoryIdentifier];
    }
    
    if ([self creatorImageURLAbsoluteString])
    {
        result[@"creatorimage"] = [self creatorImageURLAbsoluteString];
    }
    
    if (_identifier)
    {
        result[@"id"] = _identifier;
    }
    
    NSMutableArray *invitedUsers = [NSMutableArray array];
    
    for (LWFacebookUser *user in _invitedUsers)
    {
        [invitedUsers addObject:[user dictionaryRepresentation]];
    }
    
    result[@"friends"] = invitedUsers;
    
    NSMutableArray *notes = [NSMutableArray array];
    
    for (LWNote *note in _notes)
    {
        [notes addObject:[note dictionaryRepresentation]];
    }
    
    result[@"notes"] = notes;
    
    if (_fbUserId)
    {
        result[@"fbUserId"] = _fbUserId;
    }

    
    return result;
}

- (NSInteger)percentage
{
    NSDate *currentDate = [NSDate date];
    NSInteger percentage;
    
    if (_startDate == nil || _endDate == nil)
    {
        percentage = 0;
    }
    else if ([currentDate timeIntervalSinceDate:_endDate] >= 0)
    {
        percentage = 100;
    }
    else if ([currentDate timeIntervalSinceDate:_startDate] <= 0)
    {
        percentage = 0;
    }
    else
    {
        NSTimeInterval topicInterval = [_endDate timeIntervalSinceDate:_startDate];
        
        percentage = [currentDate timeIntervalSinceDate:_startDate] / topicInterval * 100;
    }
    
    return percentage;
}

- (NSString *)percentageString
{
    return [NSString stringWithFormat:@"%d%%", [self percentage]];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"identifier: %@; name: %@, ", _identifier, _name];
}

@end
