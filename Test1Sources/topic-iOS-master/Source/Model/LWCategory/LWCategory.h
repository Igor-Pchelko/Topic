//
//  LWCategory.h
//  topic
//
//  Created by Lukas K on 04.07.14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

#import "LWModel.h"

@interface LWCategory : NSObject<LWModel>

@property(nonatomic, strong) NSNumber *identifier;
@property(nonatomic, copy) NSString *name;

+ (instancetype)categoryWithIdentifier:(NSNumber *)identifier name:(NSString *)name;

@end
