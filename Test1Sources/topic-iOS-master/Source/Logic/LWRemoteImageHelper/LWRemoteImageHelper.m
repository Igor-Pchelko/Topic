//
//  Created by Lukas K on 04.07.14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

#import <objc/runtime.h>
#import "LWRemoteImageHelper.h"

@interface LWRemoteImageHelper ()

@property(nonatomic, strong) NSURLSession *urlSession;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation LWRemoteImageHelper

+ (LWRemoteImageHelper *)instance
{
    static LWRemoteImageHelper *_instance = nil;

    @synchronized (self)
    {
        if (_instance == nil)
        {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self setOperationQueue:[NSOperationQueue new]];
        [_operationQueue setMaxConcurrentOperationCount:3];
        [_operationQueue setName:@"Remote Image Fetches"];

        NSURLSessionConfiguration *sessionImageConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionImageConfiguration setTimeoutIntervalForResource:6];
        [sessionImageConfiguration setHTTPMaximumConnectionsPerHost:2];
        [sessionImageConfiguration setRequestCachePolicy:NSURLRequestUseProtocolCachePolicy];

        [self setUrlSession:[NSURLSession sessionWithConfiguration:sessionImageConfiguration delegate:nil delegateQueue:_operationQueue]];
    }

    return self;
}

- (NSURLSessionTask *)imageWithURL:(NSURL *)url
                           success:(void (^)(UIImage *image))success
                           failure:(void (^)(NSError *error))failure
{
    NSURLSessionTask *task = [_urlSession dataTaskWithURL:url
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                                        {
                                                            if (error != nil)
                                                            {
                                                                return failure(error);
                                                            }
                                                            
                                                            if (response != nil)
                                                            {
                                                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                                                                {
                                                                    UIImage *image = [UIImage imageWithData:data];
                                                                    
                                                                    dispatch_async(dispatch_get_main_queue(), ^
                                                                    {
                                                                        if (image != nil)
                                                                        {
                                                                            success(image);
                                                                        }
                                                                    });
                                                                });
                                                            }
                                                        }];

    [task resume];
    
    return task;
}

@end