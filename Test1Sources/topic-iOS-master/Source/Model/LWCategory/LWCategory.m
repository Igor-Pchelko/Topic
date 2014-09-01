//
//  LWCategory.m
//  topic
//
//  Created by Lukas K on 04.07.14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

#import "LWCategory.h"

@implementation LWCategory

- (instancetype)initWithIdentifier:(NSNumber *)identifier name:(NSString *)name
{
    self = [super init];
    
    if (self)
    {
        [self setIdentifier:identifier];
        [self setName:name];
    }

    return self;
}

+ (instancetype)categoryWithIdentifier:(NSNumber *)identifier name:(NSString *)name
{
    return [[self alloc] initWithIdentifier:identifier name:name];
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{
                @"id" : [self identifier],
                @"name" : [self name]
            };
}

@end
