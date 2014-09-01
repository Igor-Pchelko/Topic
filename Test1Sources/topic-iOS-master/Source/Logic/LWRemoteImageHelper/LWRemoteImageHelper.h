//
//  Created by Lukas K on 04.07.14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

@interface LWRemoteImageHelper : NSObject

+ (LWRemoteImageHelper *)instance;

- (NSURLSessionTask *)imageWithURL:(NSURL *)url success:(void (^)(UIImage *image))success failure:(void (^)(NSError *error))failure;

@end
