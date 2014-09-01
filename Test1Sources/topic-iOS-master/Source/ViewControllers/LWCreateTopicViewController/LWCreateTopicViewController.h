//
//  LWCreateTopicViewController.h
//  topic
//
//  Created by Lukas K on 04.07.14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

@class LWTopic;

@interface LWCreateTopicViewController : UIViewController
{
    UIDatePicker *_datePicker;
}

@property(nonatomic, strong) LWTopic *topic;

@end
