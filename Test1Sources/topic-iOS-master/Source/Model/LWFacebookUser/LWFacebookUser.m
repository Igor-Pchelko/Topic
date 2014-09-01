//
//  LWFacebookUser.m
//  topic
//
//  Created by Karen Arzumanian on 7/16/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWFacebookUser.h"

@implementation LWFacebookUser

- (instancetype)initWithIdentifier:(NSNumber *)identifier name:(NSString *)name avatarURLString:(NSString *)avatarURLString
{
    if (self = [super init])
    {
        [self setIdentifier:identifier];
        [self setName:name];
        [self setAvatarURLString:avatarURLString];
    }
    
    return self;
}

+ (instancetype)userWithIdentifier:(NSNumber *)identifier name:(NSString *)name avatarURLString:(NSString *)avatarURLString
{
    return [[self alloc] initWithIdentifier:identifier name:name avatarURLString:avatarURLString];
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:3];
    
    if (_name)
    {
        result[@"name"] = _name;
    }
    /*
    if (_identifier)
    {
        result[@"id"] = _identifier;
    }*/
    
    if (_avatarURLString)
    {
        result[@"avatarURL"] = _avatarURLString;
    }
    
    return result;
}

- (NSUInteger)hash
{
    return [_identifier hash] ^ [_name hash] ^ [_avatarURLString hash];
}

- (BOOL)isEqual:(id)theObject
{
    if (theObject == self)
    {
        return YES;
    }
    
    if (theObject == nil || ![theObject isKindOfClass:[LWFacebookUser class]])
    {
        return NO;
    }
    
    return [self isEqualToUser:theObject];
}

- (BOOL)isEqualToUser:(LWFacebookUser *)user
{
    if (_identifier != [user identifier] && ![_identifier isEqualToNumber:[user identifier]])
    {
        return NO;
    }
    
    if (_name != [user name] && ![_name isEqualToString:[user name]])
    {
        return NO;
    }
    
    if (_avatarURLString != [user avatarURLString] && ![_avatarURLString isEqualToString:[user avatarURLString]])
    {
        return NO;
    }
    
    return YES;
}

@end
