//
//  LWFbUser.m
//  topic
//
//  Created by Igor Pchelko on 8/25/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWFbUser.h"

@implementation LWFbUser

- (instancetype)initWithIdentifier:(NSNumber *)identifier facebookId:(NSString *)facebookId firstName:(NSString *)firstName lastName:(NSString *)lastName
{
    if (self = [super init])
    {
        [self setIdentifier:identifier];
        [self setFacebookId:facebookId];
        [self setFirstName:firstName];
        [self setLastName:lastName];
    }
    
    return self;
}

+ (instancetype)userWithIdentifier:(NSNumber *)identifier facebookId:(NSString *)facebookId firstName:(NSString *)firstName lastName:(NSString *)lastName
{
    return [[self alloc] initWithIdentifier:identifier facebookId:facebookId firstName:firstName lastName:lastName];
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:3];
    
    if (_identifier)
    {
        result[@"id"] = _identifier;
    }
    
    if (_facebookId)
    {
        result[@"facebookId"] = _facebookId;
    }

    if (_firstName)
    {
        result[@"firstName"] = _firstName;
    }

    if (_lastName)
    {
        result[@"lastName"] = _lastName;
    }

    return result;
}

- (NSUInteger)hash
{
    return [_identifier hash] ^ [_facebookId hash] ^ [_firstName hash] ^ [_lastName hash];
}


- (BOOL)isEqual:(id)theObject
{
    if (theObject == self)
    {
        return YES;
    }
    
    if (theObject == nil || ![theObject isKindOfClass:[LWFbUser class]])
    {
        return NO;
    }
    
    return [self isEqualToUser:theObject];
}


- (BOOL)isEqualToUser:(LWFbUser *)user
{
    if (_identifier != [user identifier] && ![_identifier isEqualToNumber:[user identifier]])
    {
        return NO;
    }
    
    if (_facebookId != [user facebookId] && ![_facebookId isEqualToString:[user facebookId]])
    {
        return NO;
    }

    if (_firstName != [user firstName] && ![_firstName isEqualToString:[user firstName]])
    {
        return NO;
    }
    
    if (_lastName != [user lastName] && ![_lastName isEqualToString:[user lastName]])
    {
        return NO;
    }
    
    return YES;
}

@end
