//
//  LWDatabaseGateway+User.h
//  topic
//
//  Created by Igor Pchelko on 8/25/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWDatabaseGateway.h"

@class LWFbUser;

@interface LWDatabaseGateway (FbUser)

+ (LWFbUser *)fbUserWithFacebookId:(NSString *)facebookId firstName:(NSString*)firstName lastName:(NSString*)lastName;
+ (BOOL)saveFbUser:(LWFbUser *)fbUser;

@end

