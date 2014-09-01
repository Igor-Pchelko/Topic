//
//  Created by Lukas K on 04.07.14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

#import "LWServerGateway.h"
#import "LWDatabaseGateway.h"
#import "LWCategory.h"
#import "LWTopic.h"
#import "LWFbUser.h"

//static NSString *const kBaseUrl = @"http://iphone.raven.php.solutions.com/";
static NSString *const kBaseUrl = @"http://localhost/topic-server-master/index.php/";
static NSString *const kTopicUploadList = @"topicUploadList";
static NSString *const kFbUserUploadList = @"fbUserUploadList";

@interface LWServerGateway ()<NSURLSessionDelegate>

@property(nonatomic, copy) NSString *token;
@property(nonatomic, strong) NSURLSession *urlSession;

@end

@implementation LWServerGateway

+ (LWServerGateway *)instance
{
    static LWServerGateway *_instance = nil;

    @synchronized (self)
    {
        if (_instance == nil)
        {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (void)setToken:(NSString *)token
{
    _token = [token mutableCopy];
    
    [self setupURLSession];
}

- (void)setupURLSession
{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setAllowsCellularAccess:YES];
    [sessionConfig setHTTPAdditionalHeaders:@{
                                                @"Accept" : @"application/json",
                                                @"TOKEN" : _token
                                             }];
    [sessionConfig setTimeoutIntervalForRequest:30.0];
    [sessionConfig setTimeoutIntervalForResource:60.0];
    [sessionConfig setHTTPMaximumConnectionsPerHost:1];
    
    [self setUrlSession:[NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil]];
}


- (void)syncWithBackend
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
    {
        if (self.fbUser != nil)
        {
            [self uploadFbUser: self.fbUser];
        }
        
        [self uploadUnsyncedTopics];

        [[_urlSession dataTaskWithURL:[self categoryAPIPathURL]
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                    {
                                        if (!error)
                                        {
                                            NSError *jsonError = nil;
                                            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];

                                            
                                            if (!jsonError && jsonResponse)
                                            {
                                                NSArray *categories = jsonResponse[@"msg"];
                            
                                                [LWDatabaseGateway updateOrInsertCategories:categories];

                                                [self fetchTopicsFromBackend];
                                            }
                                            else
                                            {
                                                [self postSyncErrorNotification];
                                            }
                                        }
                                        else
                                        {
                                            [self postSyncErrorNotification];
                                        }
                                    }] resume];
    });
}

- (void)uploadUnsyncedTopics
{
    NSArray *unsyncedTopics = [self unsyncedTopics];
    
    for (LWTopic *topic in unsyncedTopics)
    {
        [self uploadTopic:topic];
    }
}

- (void)fetchTopicsFromBackend
{
    [[_urlSession dataTaskWithURL:[self topicAPIPathURLForFbUserId:[LWServerGateway instance].fbUser.identifier]
                completionHandler:^(NSData *topicData, NSURLResponse *topicResponse, NSError *topicError)
                                {
                                    if (topicError)
                                    {
                                        [self postSyncErrorNotification];
                                        
                                        return;
                                    }

                                    NSError *topicJsonError = nil;
                                    NSDictionary *topicJsonResponse = [NSJSONSerialization JSONObjectWithData:topicData options:NSJSONReadingAllowFragments error:&topicJsonError];
                                    
                                    

                                    if (!topicJsonError && topicJsonResponse)
                                    {
                                        NSArray *topics = topicJsonResponse[@"msg"];
                                        
                                        [LWDatabaseGateway updateOrInsertTopics:topics];
                                        
                                        [self postSyncCompletedNotification];
                                    }
                                    else
                                    {
                                        [self postSyncErrorNotification];
                                    }
                               }] resume];
}

- (void)postNotificationToMainQueue:(NSString *)notificationName
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
    });
}

- (void)postSyncCompletedNotification
{
    [self postNotificationToMainQueue:kSyncCompleted];
}

- (void)postSyncErrorNotification
{
    [self postNotificationToMainQueue:kSyncFailed];
}

- (NSURL *)categoryAPIPathURL
{
    return [NSURL URLWithString:[kBaseUrl stringByAppendingString:@"category"]];
}

- (NSURL *)topicAPIPathURL
{
    return [NSURL URLWithString:[kBaseUrl stringByAppendingString:@"topic"]];
}

- (NSURL *)topicAPIPathURLForFbUserId:(NSNumber *)fbUserId
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@topic/%ld", kBaseUrl, (long)fbUserId.integerValue]];
}

- (NSURL *)topicDeleteURLForTopic:(LWTopic *)topic
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@topic/%ld", kBaseUrl, (long)topic.identifier.integerValue]];
}

- (NSURL *)fbUserAPIPathURL
{
    return [NSURL URLWithString:[kBaseUrl stringByAppendingString:@"fbuser"]];
}


- (void)setTokenAndStartSync:(NSString *)token
{
    self.token = token;
    [self syncWithBackend];
}


- (void)uploadTopic:(LWTopic *)topic
{
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[self topicAPIPathURL]];
    [urlRequest setHTTPMethod:@"POST"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:topic.dictionaryRepresentation options:NSJSONWritingPrettyPrinted error:&error];
    [urlRequest setHTTPBody:jsonData];

    [[_urlSession dataTaskWithRequest:urlRequest
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *responseError)
                                     {
                                         if (responseError)
                                         {
                                             [self addTopicToUploadList:topic];
                                         }
                                         else
                                         {
                                             NSError *jsonError;
                                             NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                                            
                                             if (jsonError)
                                             {
                                                 [self addTopicToUploadList:topic];
                                             }
                                             else
                                             {
                                                 // success
                                                 
                                                 NSLog(@"%@", responseDictionary);
                                             }
                                         }
                                     }] resume];
}

- (void)updateTopic:(LWTopic *)topic
{
    NSMutableURLRequest *urlRequest = [	NSMutableURLRequest requestWithURL:[self topicDeleteURLForTopic:topic]];
    [urlRequest setHTTPMethod:@"PUT"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:topic.dictionaryRepresentation options:NSJSONWritingPrettyPrinted error:&error];
    [urlRequest setHTTPBody:jsonData];
    
    [[_urlSession dataTaskWithRequest:urlRequest
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *responseError)
      {
          if (responseError)
          {
              [self addTopicToUploadList:topic];
          }
          else
          {
              NSError *jsonError;
              NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
              
              if (jsonError)
              {
                 // [self addTopicToUploadList:topic];
              }
              else
              {
                  // success
                  
                  NSLog(@"%@", responseDictionary);
              }
          }
      }] resume];
}

- (void)deleteTopic:(LWTopic *)topic
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
    {
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[self topicDeleteURLForTopic:topic]];
        [urlRequest setHTTPMethod:@"DELETE"];
        /*
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[topic identifier] options:NSJSONWritingPrettyPrinted error:&error];
        
        [urlRequest setHTTPBody:jsonData];
        */
        [[_urlSession dataTaskWithRequest:urlRequest
                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *responseError)
                                      {
                                          if (!responseError)
                                          {
                                              NSError *jsonError;
                                              NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                                              
                                              if (!jsonError)
                                              {
                                                  NSString *successString = responseDictionary[@"msg"];
                                                  
                                                  if ([successString.lowercaseString isEqualToString:@"success"])
                                                  {
                                                      return;
                                                  }
                                              }
                                          }
                                      }] resume];
    });
}


- (NSArray *)unsyncedTopics
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSArray *topicIDS = [[userDefaults objectForKey:kTopicUploadList] copy];
    [userDefaults removeObjectForKey:kTopicUploadList];
    [userDefaults synchronize];
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:topicIDS.count];
    
    for (NSNumber *topicID in topicIDS)
    {
        [result addObject:[LWDatabaseGateway topicWithIdentifier:topicID]];
    }

    [result addObjectsFromArray:[LWDatabaseGateway notUploadedTopics]];
    NSLog(@"result: %@", result);

    return result;
}

- (void)addTopicToUploadList:(LWTopic *)topic
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSMutableArray *array = [[userDefaults objectForKey:kTopicUploadList] mutableCopy];
    
    if (!array)
    {
        array = [NSMutableArray array];
    }
    
    if (![array containsObject:[topic identifier]])
    {
        [array addObject:[topic identifier]];
        
        [userDefaults setObject:array forKey:kTopicUploadList];
        [userDefaults synchronize];
    }
}


- (void)uploadFbUser:(LWFbUser *)fbUser
{
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[self fbUserAPIPathURL]];
    [urlRequest setHTTPMethod:@"POST"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:fbUser.dictionaryRepresentation options:NSJSONWritingPrettyPrinted error:&error];
    [urlRequest setHTTPBody:jsonData];
    
    [[_urlSession dataTaskWithRequest:urlRequest
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *responseError)
      {
          if (responseError)
          {
              [self addFbUserToUploadList:fbUser];
          }
          else
          {
              NSError *jsonError;
              NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
              
              if (jsonError)
              {
                  [self addFbUserToUploadList:fbUser];
              }
              else
              {
                  // success
                  NSLog(@"%@", responseDictionary);
              }
          }
      }] resume];
}


- (void)deleteFbUser:(LWFbUser *)fbUser
{
    // TODO:
}


- (void)addFbUserToUploadList:(LWFbUser *)fbUser
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *array = [[userDefaults objectForKey:kTopicUploadList] mutableCopy];
    
    if (!array)
    {
        array = [NSMutableArray array];
    }

    if ([array containsObject:[fbUser identifier]])
        [array removeObject:[fbUser identifier]];
    
    [array addObject:[fbUser identifier]];
        
    [userDefaults setObject:array forKey:kFbUserUploadList];
    [userDefaults synchronize];
}

@end