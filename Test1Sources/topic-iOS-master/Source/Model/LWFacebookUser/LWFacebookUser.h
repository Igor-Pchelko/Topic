//
//  LWFacebookUser.h
//  topic
//
//  Created by Karen Arzumanian on 7/16/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWModel.h"

@interface LWFacebookUser : NSObject<LWModel>

@property(nonatomic, strong) NSNumber *identifier;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *avatarURLString;

- (instancetype)initWithIdentifier:(NSNumber *)identifier name:(NSString *)name avatarURLString:(NSString *)avatarURLString;
+ (instancetype)userWithIdentifier:(NSNumber *)identifier name:(NSString *)name avatarURLString:(NSString *)avatarURLString;

@end
