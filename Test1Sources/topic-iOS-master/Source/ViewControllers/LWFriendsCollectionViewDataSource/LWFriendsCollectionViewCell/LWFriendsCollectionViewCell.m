//
//  LWFriendsCollectionViewCell.m
//  topic
//
//  Created by Karen Arzumanian on 7/16/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWFriendsCollectionViewCell.h"
#import "UIImage+RemoteImage.h"

@interface LWFriendsCollectionViewCell ()

@property(weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation LWFriendsCollectionViewCell

- (void)setImageURL:(NSURL *)url
{
    [_imageView setImageWithURL:url placeholderImage:nil];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [_imageView setImage:nil];
}

@end
