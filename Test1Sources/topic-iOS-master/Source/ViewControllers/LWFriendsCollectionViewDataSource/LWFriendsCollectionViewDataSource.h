//
//  LWFriendsCollectionViewDataSource.h
//  topic
//
//  Created by Karen Arzumanian on 7/16/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

@interface LWFriendsCollectionViewDataSource : NSObject<UICollectionViewDataSource>

@property(strong, nonatomic) NSArray *friends; // |NSArray| of |LWFacebookUser| objects

@end
