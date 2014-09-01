//
//  LWFbUser.h
//  topic
//
//  Created by Igor Pchelko on 8/25/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWModel.h"

@interface LWFbUser : NSObject<LWModel>

@property(nonatomic, strong) NSNumber *identifier;
@property(nonatomic, copy) NSString *facebookId;
@property(nonatomic, copy) NSString *firstName;
@property(nonatomic, copy) NSString *lastName;

- (instancetype)initWithIdentifier:(NSNumber *)identifier facebookId:(NSString *)facebookId firstName:(NSString *)firstName lastName:(NSString *)lastName;
+ (instancetype)userWithIdentifier:(NSNumber *)identifier facebookId:(NSString *)facebookId firstName:(NSString *)firstName lastName:(NSString *)lastName;

@end
