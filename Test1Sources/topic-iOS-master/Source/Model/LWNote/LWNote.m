//
//  LWNote.m
//  topic
//
//  Created by Admin on 7/23/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWNote.h"
#import "NSDate+ServerGateway.h"

@implementation LWNote

- (instancetype)initWithIdentifier:(NSNumber *)identifier name:(NSString *)name description:(NSString *)description date:(NSDate *)date topicId:(NSNumber *)topicId
{
    if (self = [super init])
    {
        [self setIdentifier:identifier];
        [self setName:name];
        [self setDescription:description];
        [self setDate:date];
        [self setAdded:FALSE];
        [self setTopicId:topicId];
    }
    
    return self;
}

+ (instancetype)noteWithIdentifier:(NSNumber *)identifier name:(NSString *)name description:(NSString *)description date:(NSDate *)date topicId:(NSNumber *)topicId
{
    return [[self alloc] initWithIdentifier:identifier name:name description:description date:date topicId:topicId];
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:3];
    
    if (_name)
    {
        result[@"name"] = _name;
    }
    
    if (_description)
    {
        result[@"description"] = _description;
    }

    NSString *date = _date ? [NSDate apiStringFromDateWithoutSeconds:_date] : [NSDate apiStringFromDateWithoutSeconds:[NSDate date]];
    
    if (date)
    {
        result[@"date"] = date;
    }

    if (_topicId)
    {
        result[@"topicId"] = _topicId;
    }
    
    return result;
}

- (NSUInteger)hash
{
    return [_identifier hash] ^ [_name hash] ^ [_description hash] ^ [_date hash];
}

- (BOOL)isEqual:(id)theObject
{
    if (theObject == self)
    {
        return YES;
    }
    
    if (theObject == nil || ![theObject isKindOfClass:[LWNote class]])
    {
        return NO;
    }
    
    return [self isEqualToNote:theObject];
}

- (BOOL)isEqualToNote:(LWNote *)note
{
    if (_identifier != [note identifier] && ![_identifier isEqualToNumber:[note identifier]])
    {
        return NO;
    }
    
    if (_name != [note name] && ![_name isEqualToString:[note name]])
    {
        return NO;
    }
    
    if (_description != [note description] && ![_description isEqualToString:[note description]])
    {
        return NO;
    }
    
    if (_date != [note date] && ![_date isEqualToDate:[note date]])
    {
        return NO;
    }
    
    if (_topicId != [note topicId] && ![_topicId isEqualToNumber:[note topicId]])
    {
        return NO;
    }
    
    return YES;
}


@end
