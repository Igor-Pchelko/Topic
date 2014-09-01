//
//  LWTopicControllerViewController.h
//  topic
//
//  Created by Igor Pchelko on 27/08/2014.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LWTopic;
@class LWNote;

@interface LWNoteControllerViewController : UIViewController

@property(nonatomic, strong) LWTopic *topic;
@property(nonatomic, strong) LWNote *note;

@end


