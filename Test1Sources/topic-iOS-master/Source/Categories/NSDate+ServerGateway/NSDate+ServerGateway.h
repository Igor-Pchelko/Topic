//
//  NSDate+ServerGateway.h
//  topic
//
//  Created by Karen Arzumanian on 7/14/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

@interface NSDate (ServerGateway)

+ (NSDate *)dateFromAPITimeString:(NSString *)dateString;
+ (NSString *)apiStringFromDate:(NSDate *)date;
+ (NSString *)apiStringFromDateWithoutSeconds:(NSDate *)date;

@end
