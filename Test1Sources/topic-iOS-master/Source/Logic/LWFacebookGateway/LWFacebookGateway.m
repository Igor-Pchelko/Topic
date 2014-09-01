//
//  LWFacebookGateway.m
//  topic
//
//  Created by Karen Arzumanian on 7/16/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWFacebookGateway.h"
#import <FacebookSDK/FacebookSDK.h>
#import "LWFacebookUser.h"

@implementation LWFacebookGateway

+ (void)presentRequestsDialogModallyWithCompletionHandler:(LWFacebookGatewayRequestsHandler)completion
{
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:@"test"
                                                    title:nil
                                               parameters:nil
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
                                                        {
                                                            if (error)
                                                            {
                                                                // Error launching the dialog or sending the request.
                                                                NSLog(@"Error sending request.");
                                                            }
                                                            else
                                                            {
                                                                if (result == FBWebDialogResultDialogNotCompleted)
                                                                {
                                                                    // User clicked the "x" icon
                                                                    NSLog(@"User canceled request.");
                                                                }
                                                                else
                                                                {
                                                                    // Handle the send request callback
                                                                    NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                                     
                                                                    if (![urlParams valueForKey:@"request"])
                                                                    {
                                                                        // User clicked the Cancel button
                                                                        NSLog(@"User canceled request.");
                                                                    }
                                                                    else
                                                                    {
                                                                        // User clicked the Send button
                                                                        NSString *requestID = [urlParams valueForKey:@"request"];
                                                                        NSLog(@"Request ID: %@", requestID);
                                                                    }
                                                                    
                                                                    if (completion != NULL)
                                                                    {
                                                                        completion(urlParams, error);
                                                                    }
                                                                }
                                                            }
                                                        }];
}

+ (void)userInfoByID:(NSString *)identifier withCompletionHandler:(LWFacebookGatewayUserInfoRequestHandler)completion
{
    [FBRequestConnection startWithGraphPath:[@"/" stringByAppendingString:identifier]
                                 parameters:@{@"fields" : @"picture, id, name"}
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
                                        {
                                            LWFacebookUser *user;
                                            
                                            if (!error)
                                            {
                                                user = [self userFromResult:result];
                                            }
                                            
                                            if (completion != NULL)
                                            {
                                                completion(user, error);
                                            }
                                        }];
}

+ (void)currentUserInfoWithCompletionHandler:(LWFacebookGatewayUserInfoRequestHandler)completion
{
    [FBRequestConnection startWithGraphPath:@"me"
                                 parameters:[NSDictionary dictionaryWithObject:@"picture,id" forKey:@"fields"]
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
                                         {
                                             LWFacebookUser *user;
                                             
                                             if (!error)
                                             {
                                                 user = [self userFromResult:result];
                                             }
                                             
                                             if (completion != NULL)
                                             {
                                                 completion(user, error);
                                             }
                                         }];
}

+ (NSDictionary *)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    for (NSString *pair in pairs)
    {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        
        if (![kv[0] isEqualToString:@"request"])
        {
            [params setObject:[kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                       forKey:[kv[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    return params;
}

+ (LWFacebookUser *)userFromResult:(id)result
{
    LWFacebookUser *user = [LWFacebookUser new];
    
    if (result && [result isKindOfClass:[NSDictionary class]])
    {
        id identifier = result[@"identifier"];
        
        if (identifier && [identifier isKindOfClass:[NSString class]])
        {
            [user setIdentifier:identifier];
        }
        
        id name = result[@"name"];
        
        if (name && [name isKindOfClass:[NSString class]])
        {
            [user setName:name];
        }
        
        id url = result[@"picture"][@"data"][@"url"];
        
        if (url && [url isKindOfClass:[NSString class]])
        {
            [user setAvatarURLString:url];
        }
    }
    
    return user;
}

@end
