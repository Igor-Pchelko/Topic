//
//  LWNotesCell.h
//  topic
//
//  Created by Admin on 7/23/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

@class LWNote;
@class LWTopicDetailViewController;

@interface LWNotesCell : UITableViewCell <UITextFieldDelegate>

@property(weak, nonatomic) IBOutlet UIView *noteView;
@property(weak, nonatomic) IBOutlet UILabel *nameLabel;
@property(weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descTextField;
@property(weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property(nonatomic, strong) LWNote *note;
@property(nonatomic, assign) BOOL toTheRight;
@property(nonatomic, assign) BOOL added;

@property(weak, nonatomic) LWTopicDetailViewController *controler; // could be replaced by protocol


@end
