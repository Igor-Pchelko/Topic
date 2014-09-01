//
//  Created by Lukas K on 04.07.14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

@class LWTopic;
@class LWFbUser;

static NSString *const kSyncCompleted = @"SyncCompleted";
static NSString *const kSyncFailed = @"SyncFailed";

@interface LWServerGateway : NSObject

+ (LWServerGateway *)instance;

@property (strong, nonatomic) LWFbUser *fbUser;

- (void)syncWithBackend;
- (void)setTokenAndStartSync:(NSString *)token;
- (void)uploadTopic:(LWTopic *)topic;
- (void)updateTopic:(LWTopic *)topic;
- (void)deleteTopic:(LWTopic *)topic;

- (void)uploadFbUser:(LWFbUser *)fbUser;

@end