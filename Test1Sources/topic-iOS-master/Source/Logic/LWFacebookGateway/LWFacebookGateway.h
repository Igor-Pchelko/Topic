//
//  LWFacebookGateway.h
//  topic
//
//  Created by Karen Arzumanian on 7/16/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

@class LWFacebookUser;

typedef void (^LWFacebookGatewayRequestsHandler)(NSDictionary *friends, NSError *error);
typedef void (^LWFacebookGatewayUserInfoRequestHandler)(LWFacebookUser *userInfo, NSError *error);

@interface LWFacebookGateway : NSObject

+ (void)presentRequestsDialogModallyWithCompletionHandler:(LWFacebookGatewayRequestsHandler)completion;
+ (void)userInfoByID:(NSString *)identifier withCompletionHandler:(LWFacebookGatewayUserInfoRequestHandler)completion;
+ (void)currentUserInfoWithCompletionHandler:(LWFacebookGatewayUserInfoRequestHandler)completion;

@end

