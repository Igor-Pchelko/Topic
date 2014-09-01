//
//  LWTopicDetailViewController.h
//  topic
//
//  Created by Karen Arzumanian on 7/16/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

@class LWTopic;
@class LWNote;

@interface LWTopicDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) LWTopic *topic;

- (void)editNote:(LWNote*)note;

@end
