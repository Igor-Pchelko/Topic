//
//  LWTopicControllerViewController.m
//  topic
//
//  Created by Igor Pchelko on 27/08/2014.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "LWNoteControllerViewController.h"
#import "LWTopic.h"
#import "LWNote.h"
#import "LWFacebookGateway.h"
#import "LWFacebookUser.h"
#import "UIImage+RemoteImage.h"
#import "LWFriendsCollectionViewDataSource.h"
#import "LWDatabaseGateway.h"
#import "LWServerGateway.h"

@interface LWNoteControllerViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property(weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@property(strong, nonatomic) LWFriendsCollectionViewDataSource *friendsCollectionViewDataSource;

@end

@implementation LWNoteControllerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:[_topic name]];

    [self loadCreatorInfo];
    [self setupFriendsCollectionView];

    // Setup texts
    [self.nameTextField setText:self.note.name];
    [self.descriptionTextView setText:self.note.description];
    
    [self.nameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadCreatorInfo
{
    if (![_topic creatorImageURL] || [[_topic creatorImageURLAbsoluteString] length] <= 0)
    {
        [LWFacebookGateway currentUserInfoWithCompletionHandler:^(LWFacebookUser *userInfo, NSError *error)
         {
             NSURL *url = [NSURL URLWithString:[userInfo avatarURLString]];
             [_topic setCreatorImageURL:url];
             [_avatarImageView setImageWithURL:[_topic creatorImageURL] placeholderImage:nil];
         }];
    }
    else
    {
        [_avatarImageView setImageWithURL:[_topic creatorImageURL] placeholderImage:nil];
    }
}

- (void)setupFriendsCollectionView
{
    [self setFriendsCollectionViewDataSource:[LWFriendsCollectionViewDataSource new]];
    [_collectionView setDataSource:_friendsCollectionViewDataSource];
    [_friendsCollectionViewDataSource setFriends:[_topic invitedUsers]];
    [_collectionView reloadData];
}

- (IBAction)saveDidPress:(id)sender
{
    if ([self.nameTextField.text isEqualToString:@""] || [self.descriptionTextView.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:@"Please fill in the textfields."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    [self.note setName:self.nameTextField.text];
    [self.note setDescription:self.descriptionTextView.text];
    [self.note setAdded:FALSE];
    
    NSMutableArray *notes = [_topic.notes mutableCopy];
    
    if (notes == nil)
        notes = [NSMutableArray array];
    
    NSUInteger ix = [notes indexOfObject:self.note];
    
    if (ix == NSNotFound)
        [notes insertObject:self.note atIndex:0];
    else
        [notes setObject:self.note atIndexedSubscript:ix];
    
    [_topic setNotes:notes];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
                   {
                       [LWDatabaseGateway saveTopic:_topic];
                       [[LWServerGateway instance] updateTopic:_topic];
                   });
    
    [[self navigationController] popViewControllerAnimated:YES];
}



@end
