//
//  UIImage+RemoteImage.m
//  topic
//
//  Created by Lukas K on 04.07.14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

#import "UIImage+RemoteImage.h"
#import "LWRemoteImageHelper.h"

@implementation UIImageView (RemoteImage_Private)

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImage:placeholder];
    
    [[LWRemoteImageHelper instance] imageWithURL:url
                                                                          success:^(UIImage *image)
                                                                                {
                                                                                    [self setImage:image];
                                                                                }
                                                                          failure:^(NSError *error)
                                                                                {
                                                                                    NSLog(@"Error fetching image: %@", error.localizedDescription);
                                                                                }];
}

@end