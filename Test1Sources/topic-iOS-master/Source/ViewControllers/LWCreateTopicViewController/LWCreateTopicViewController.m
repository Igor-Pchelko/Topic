//
//  LWCreateTopicViewController.m
//  topic
//
//  Created by Lukas K on 04.07.14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

#import "LWCreateTopicViewController.h"
#import "LWDatabaseGateway.h"
#import "LWServerGateway.h"
#import "LWTopic.h"
#import "LWCategory.h"
#import "UIImage+RemoteImage.h"
#import "LWFacebookGateway.h"
#import "LWFriendsCollectionViewDataSource.h"
#import "LWFacebookUser.h"
#import "NSDate+ServerGateway.h"

#import "LWServerGateway.h"
#import "LWFbUser.h"

@interface LWCreateTopicViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property(weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property(weak, nonatomic) IBOutlet UITextField *topicName;
@property(weak, nonatomic) IBOutlet UIButton *categoryButton;
@property(weak, nonatomic) IBOutlet UITextField *startTime;
@property(weak, nonatomic) IBOutlet UITextField *stopTime;
@property(weak, nonatomic) IBOutlet UIButton *startTimeButton;
@property(weak, nonatomic) IBOutlet UIButton *stopTimeButton;
@property(weak, nonatomic) IBOutlet UIImageView *creatorImageView;
@property(weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *invitedFriendsCountLabel;
@property(nonatomic, strong) NSArray *categories;
@property(strong, nonatomic) LWFriendsCollectionViewDataSource *friendsCollectionViewDataSource;

@end

@implementation LWCreateTopicViewController

- (LWTopic *)topic
{
    if (!_topic)
    {
        _topic = [[LWTopic alloc] init];
    }
    
    return _topic;
}

- (void)loadCreatorImage
{
    if (![_topic creatorImageURL] || [[_topic creatorImageURLAbsoluteString] length] <= 0)
    {
        [LWFacebookGateway currentUserInfoWithCompletionHandler:^(LWFacebookUser *userInfo, NSError *error)
        {
            NSURL *url = [NSURL URLWithString:[userInfo avatarURLString]];
            [_topic setCreatorImageURL:url];
            [_creatorImageView setImageWithURL:[_topic creatorImageURL] placeholderImage:nil];
        }];
    }
    else
    {
        [_creatorImageView setImageWithURL:[_topic creatorImageURL] placeholderImage:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self loadCreatorImage];

    self.topicName.text = self.topic.name;
    self.topicName.delegate = self;

    NSString *categoryName = self.topic.category.name;
    
    if (categoryName && categoryName.length > 0)
    {
        [self.categoryButton setTitle:categoryName forState:UIControlStateNormal];
    }

    self.startTime.placeholder = [NSDate apiStringFromDateWithoutSeconds:[NSDate date]];
    self.stopTime.placeholder = [NSDate apiStringFromDateWithoutSeconds:[NSDate date]];

    [self.categoryButton addTarget:self action:@selector(selectCategory:) forControlEvents:UIControlEventTouchUpInside];
    [self.startTimeButton addTarget:self action:@selector(selectTime:) forControlEvents:UIControlEventTouchUpInside];
    [self.stopTimeButton addTarget:self action:@selector(selectTime:) forControlEvents:UIControlEventTouchUpInside];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];

    [self.view addGestureRecognizer:tap];
    
    [self setFriendsCollectionViewDataSource:[LWFriendsCollectionViewDataSource new]];
    [_collectionView setDataSource:_friendsCollectionViewDataSource];
    [_collectionView reloadData];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)selectTime:(UIButton *)sender {
    self.categories = [LWDatabaseGateway fetchAllCategories];
    UIView *clickRemover = [[UIView alloc] initWithFrame:self.view.frame];
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame) - 250, CGRectGetWidth(self.view.frame), 250)];
    container.backgroundColor = [UIColor whiteColor];
    container.layer.borderColor = [UIColor lightGrayColor].CGColor;
    container.layer.borderWidth = 0.5f;

    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeSystem];
    okButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [okButton setFrame:CGRectMake(CGRectGetMaxX(container.frame) - 80, 0, 80, 44)];
    [okButton setTitle:@"OK" forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(clickedOK:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:okButton];

    UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(okButton.frame), CGRectGetWidth(container.frame), 1)];
    dividerView.backgroundColor = [UIColor lightGrayColor];
    [container addSubview:dividerView];

    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(dividerView.frame), CGRectGetWidth(container.frame), 200)];
    _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    if ([sender isEqual:self.startTimeButton]) {
        container.tag = 456;
        _datePicker.date = (self.topic.startDate) ? self.topic.startDate : [NSDate date];
        _datePicker.maximumDate = self.topic.endDate;
    } else {
        container.tag = 654;
        _datePicker.date = (self.topic.endDate) ? self.topic.endDate : [NSDate date];
        _datePicker.minimumDate = self.topic.startDate;
    }

    [container addSubview:_datePicker];
    [self.view addSubview:container];
    [clickRemover addSubview:container];
    [self.view addSubview:clickRemover];
}

- (void)selectCategory:(UIButton *)sender {
    CGRect senderFrame = sender.frame;

    self.categories = [LWDatabaseGateway fetchAllCategories];

    UIView *clickRemover = [[UIView alloc] initWithFrame:self.view.frame];
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(senderFrame), CGRectGetMaxY(senderFrame), CGRectGetWidth(senderFrame), 194)];
    container.backgroundColor = [UIColor whiteColor];
    container.layer.borderColor = [UIColor lightGrayColor].CGColor;
    container.layer.borderWidth = 0.5f;
    container.tag = 123;

    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeSystem];
    okButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [okButton setFrame:CGRectMake(CGRectGetMaxX(container.frame) - 90, 0, 80, 44)];
    [okButton setTitle:@"OK" forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(clickedOK:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:okButton];

    UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(okButton.frame), CGRectGetWidth(senderFrame), 1)];
    dividerView.backgroundColor = [UIColor lightGrayColor];
    [container addSubview:dividerView];

    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(dividerView.frame), CGRectGetWidth(senderFrame), 150)];
    pickerView.dataSource = self;
    pickerView.delegate = self;

    [container addSubview:pickerView];
    [clickRemover addSubview:container];
    [self.view addSubview:clickRemover];

    if (!self.topic.category) {
        [self pickerView:pickerView didSelectRow:0 inComponent:1];
    }
}

- (void)inviteFriends
{
    [LWFacebookGateway presentRequestsDialogModallyWithCompletionHandler:^(NSDictionary *friendsID, NSError *error)
    {
        if (error)
        {
            // TODO: handle error
        }
        else
        {
            for (NSString *friendID in [friendsID allValues])
            {
                [LWFacebookGateway userInfoByID:friendID
                          withCompletionHandler:^(LWFacebookUser *userInfo, NSError *error)
                                             {
                                                 NSMutableArray *friends = [[_friendsCollectionViewDataSource friends] mutableCopy];
                                                 
                                                 if (friends == nil)
                                                 {
                                                     friends = [NSMutableArray array];
                                                 }
                                                 
                                                 if (userInfo != nil && ![friends containsObject:userInfo])
                                                 {
                                                     [friends addObject:userInfo];
                                                     
                                                     [_friendsCollectionViewDataSource setFriends:friends];
                                                     [_collectionView reloadData];
                                                     
                                                     [_invitedFriendsCountLabel setText:[NSString stringWithFormat:@"%d", [friends count]]];
                                                 }
                                             }];
            }
        }
    }];
}

- (void)clickedOK:(UIButton *)clickedOK {
    UIView *superView = clickedOK.superview;
    if (superView.tag == 456) {
        self.topic.startDate = _datePicker.date;
        self.startTime.text = [NSDate apiStringFromDateWithoutSeconds:[_topic startDate]];
    } else if (superView.tag == 654) {
        self.topic.endDate = _datePicker.date;
        self.stopTime.text = [NSDate apiStringFromDateWithoutSeconds:[_topic endDate]];
    }
    [superView.superview removeFromSuperview];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.categories.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    LWCategory *category = self.categories[(NSUInteger) row];
    return category.name;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    LWCategory *category = self.categories[(NSUInteger) row];
    [self.categoryButton setTitle:category.name forState:UIControlStateNormal];
    self.topic.category = category;
}

- (IBAction)saveTopic:(id)sender
{
    [_topic setName:[_topicName text]];
    [_topic setInvitedUsers:[_friendsCollectionViewDataSource friends]];
    self.topic.fbUserId = [LWServerGateway instance].fbUser.identifier;

    BOOL saved = [LWDatabaseGateway saveTopic:[self topic]];
    
    if (saved)
    {
        [[[UIAlertView alloc] initWithTitle:@"Saved" message:@"Topic was successfully saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [[LWServerGateway instance] uploadTopic:[self topic]];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Fault" message:@"There was a problem saving your topic. Check if all values are present" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.topicName]) {
        self.topic.name = textField.text;
    }
}

- (IBAction)inviteButtonTapped:(id)sender
{
    [self inviteFriends];
}

@end
