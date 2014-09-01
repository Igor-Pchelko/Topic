//
//  UIImage+RemoteImage.h
//  topic
//
//  Created by Lukas K on 04.07.14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (RemoteImage)

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

@end