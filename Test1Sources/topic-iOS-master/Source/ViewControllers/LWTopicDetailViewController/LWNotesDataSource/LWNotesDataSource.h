//
//  LWNotesDataSource.h
//  topic
//
//  Created by Admin on 7/23/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

@class LWTopicDetailViewController;

@interface LWNotesDataSource : NSObject<UITableViewDataSource>

@property(strong, nonatomic) NSArray *notes; // |NSArray| of |LWNotes| objects
@property(weak, nonatomic) LWTopicDetailViewController *controler; // could be replaced by protocol

@end
