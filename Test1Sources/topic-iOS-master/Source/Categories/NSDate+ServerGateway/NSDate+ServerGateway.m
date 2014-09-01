//
//  NSDate+ServerGateway.m
//  topic
//
//  Created by Karen Arzumanian on 7/14/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "NSDate+ServerGateway.h"

static NSString * const dateAndTimeFormat               = @"YYYY-MM-dd HH:mm:ss";
static NSString * const dateAndTimeWithoutSecondsFormat = @"YYYY-MM-dd HH:mm";

@implementation NSDate (ServerGateway)

+ (NSDate *)dateFromAPITimeString:(NSString *)dateString
{
    NSAssert(dateString != nil, @"Only string with date can be converted");
    
    NSDateFormatter *apiDateFormatter = [NSDateFormatter new];
    [apiDateFormatter setDateFormat:dateAndTimeFormat];

    return [apiDateFormatter dateFromString:dateString];
}

+ (NSString *)apiStringFromDate:(NSDate *)date
{
    NSAssert(date != nil, @"Only dates can be converted");
    
    NSDateFormatter *apiDateFormatter = [NSDateFormatter new];
    [apiDateFormatter setDateFormat:dateAndTimeFormat];
    
    return [apiDateFormatter stringFromDate:date];
}

+ (NSString *)apiStringFromDateWithoutSeconds:(NSDate *)date
{
    NSAssert(date != nil, @"Only dates can be converted");
    
    NSDateFormatter *apiDateFormatter = [NSDateFormatter new];
    [apiDateFormatter setDateFormat:dateAndTimeWithoutSecondsFormat];
    
    return [apiDateFormatter stringFromDate:date];
}

@end
