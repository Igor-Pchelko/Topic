//
//  LWFriendsCollectionViewDataSource.m
//  topic
//
//  Created by Karen Arzumanian on 7/16/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWFriendsCollectionViewDataSource.h"
#import "LWFriendsCollectionViewCell.h"
#import "LWFacebookUser.h"

@implementation LWFriendsCollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_friends count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LWFriendsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([LWFriendsCollectionViewCell class]) forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[LWFriendsCollectionViewCell alloc] init];
    }
    
    LWFacebookUser *user = _friends[[indexPath row]];
    
    [cell setImageURL:[NSURL URLWithString:[user avatarURLString]]];
    
    return cell;
}

@end
