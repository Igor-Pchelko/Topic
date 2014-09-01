//
//  LWTopicDetailViewController.m
//  topic
//
//  Created by Karen Arzumanian on 7/16/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "LWTopicDetailViewController.h"
#import "LWTopic.h"
#import "LWNote.h"
#import "LWDatabaseGateway.h"
#import "LWServerGateway.h"
#import "UIImage+RemoteImage.h"
#import "LWFacebookGateway.h"
#import "LWFriendsCollectionViewDataSource.h"
#import "LWFacebookUser.h"
#import "LWNotesCell.h"
#import "LWNotesDataSource.h"
#import "LWSideMenuController.h"
#import "LWNoteControllerViewController.h"

@interface LWTopicDetailViewController ()

@property(weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property(weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property(weak, nonatomic) IBOutlet UILabel *percentageLabel;
@property(weak, nonatomic) IBOutlet UITableView *tableView;

@property(strong, nonatomic) LWNotesDataSource *notesDataSource;

@property(strong, nonatomic) LWFriendsCollectionViewDataSource *friendsCollectionViewDataSource;

@property(strong, nonatomic) LWSideMenuController *menuViewController;

@end

@implementation LWTopicDetailViewController

NSArray *menuArr;
BOOL isAdding;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:[_topic name]];
    
    [self loadCreatorInfo];
    
    [_percentageLabel setText:[_topic percentageString]];
    
    [self setupFriendsCollectionView];
    [self setupNotesTableView];

    [self addTapGestureRecognizer];
    
    menuArr = [NSArray arrayWithObjects:@"MY PROFILE", @"Log out", @"Add Note", @"TOPICS", @"All Topics", nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.navigationController.view addGestureRecognizer:panGestureRecognizer];
    


    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SideMenuController"];
    self.menuViewController.view.tag = 100;
    self.menuViewController.tableView.delegate = self;
    self.menuViewController.tableView.dataSource = self;
    self.menuViewController.tableView.backgroundColor = [self.menuViewController.tableView.backgroundColor colorWithAlphaComponent:0.9];
    [self.navigationController.view addSubview:self.menuViewController.view];
    UIView *menuView = [self.navigationController.view viewWithTag:100];
    CGRect mDestination = menuView.frame;
    mDestination.origin.x = -320;
    mDestination.origin.y = 20;
    mDestination.size.height -= 20;
    menuView.frame = mDestination;
    
    
    [_notesDataSource setNotes:[_topic notes]];
    [_tableView reloadData];
    isAdding = FALSE;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UIView *menuView = [self.navigationController.view viewWithTag:100];
    [menuView removeFromSuperview];
    self.menuViewController = nil;
    
    for (UIGestureRecognizer *recognizer in self.navigationController.view.gestureRecognizers) {
        [self.navigationController.view removeGestureRecognizer:recognizer];
    }
}

- (void)setupFriendsCollectionView
{
    [self setFriendsCollectionViewDataSource:[LWFriendsCollectionViewDataSource new]];
    [_collectionView setDataSource:_friendsCollectionViewDataSource];
    [_friendsCollectionViewDataSource setFriends:[_topic invitedUsers]];
    [_collectionView reloadData];
}

- (void)setupNotesTableView
{
    LWNotesDataSource *ds = [LWNotesDataSource new];
    ds.controler = self;
    [self setNotesDataSource:ds];
    [_tableView setDataSource:_notesDataSource];
    [_notesDataSource setNotes:[_topic notes]];
    [_tableView reloadData];
}

- (void)addTapGestureRecognizer
{
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addNote)];
    [recognizer setNumberOfTapsRequired:1];
    [recognizer setNumberOfTouchesRequired:1];
    [_tableView addGestureRecognizer:recognizer];
}


- (void)editNote:(LWNote*)note
{
    LWNoteControllerViewController *viewController = [[self storyboard] instantiateViewControllerWithIdentifier:NSStringFromClass([LWNoteControllerViewController class])];
    [viewController setTopic:_topic];
    viewController.note = note;
    [[self navigationController] pushViewController:viewController animated:YES];
}

- (void)addNote
{
    if (isAdding)
        return;
    
    isAdding = TRUE;
    
    LWNote *note = [LWNote noteWithIdentifier:nil name:@"" description:@"" date:[NSDate date] topicId:nil];
    [note setAdded:TRUE];
    
    // Ok, lets open topic note
    LWNoteControllerViewController *viewController = [[self storyboard] instantiateViewControllerWithIdentifier:NSStringFromClass([LWNoteControllerViewController class])];
    [viewController setTopic:_topic];
    viewController.note = note;
    [[self navigationController] pushViewController:viewController animated:YES];
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
             [_usernameLabel setText:[userInfo name]];
         }];
    }
    else
    {
        [_avatarImageView setImageWithURL:[_topic creatorImageURL] placeholderImage:nil];
    }
}

- (void)removeTopic
{
    if ([LWDatabaseGateway removeTopic:_topic])
    {
        [[LWServerGateway instance] deleteTopic:_topic];
        
        [[self navigationController] popViewControllerAnimated:YES];
        
        [[[UIAlertView alloc] initWithTitle:@"Removed" message:@"Topic was successfully removed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Fault" message:@"There was a problem removing your topic." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    static CGPoint originalCenter;
    static UIView *menuView;
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        menuView = [self.navigationController.view viewWithTag:100];
        originalCenter = menuView.center;
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:self.view];
        if (translation.x > 0 && menuView.center.x == 90)
            return;
        
        menuView.center = CGPointMake(originalCenter.x + translation.x, originalCenter.y);
        if (menuView.center.x < -160)
            menuView.center = CGPointMake(-160, originalCenter.y);
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed)
    {
        CGPoint translation = [recognizer translationInView:self.view];
        if (translation.x > 0) {
            [UIView animateWithDuration:0.25 animations:^{
                menuView.center = CGPointMake(90, originalCenter.y);
            }];
        } else if (translation.x < 0) {
            [UIView animateWithDuration:0.25 animations:^{
                menuView.center = CGPointMake(-160, originalCenter.y);
            }];
        }
    }
}

- (IBAction)trashButtonTapped:(id)sender
{
    [self removeTopic];
}

- (IBAction)onNoteCancel:(id)sender
{
    /*
    [notes removeObjectAtIndex:0];
    [_notesDataSource setNotes:notes];
    [_tableView reloadData];
    isAdding = FALSE;
    */
}

- (IBAction)onNoteSave:(id)sender
{
    /*
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    LWNotesCell *cell = (LWNotesCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.nameTextField.text isEqualToString:@""] || [cell.descTextField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:@"Please fill in the textfields."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    LWNote *note = [notes objectAtIndex:0];
    [note setName:cell.nameTextField.text];
    [note setDescription:cell.descTextField.text];
    [note setAdded:FALSE];
    [notes setObject:note atIndexedSubscript:0];
    
    [_topic setNotes:notes];
    [_notesDataSource setNotes:notes];
    [_tableView reloadData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
     {
         [LWDatabaseGateway saveTopic:_topic];
         [[LWServerGateway instance] updateTopic:_topic];
     });
    
    isAdding = FALSE;
    */
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.row == 0 || indexPath.row == 3)
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellCategory" forIndexPath:indexPath];
    else
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellItem" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [menuArr objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 1:{
            UIView *menuView = [self.navigationController.view viewWithTag:100];
            [menuView removeFromSuperview];
            FBSession* session = [FBSession activeSession];
            [session closeAndClearTokenInformation];
            [session close];
            [FBSession setActiveSession:nil];
            
            /*NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray* facebookCookies = [cookies cookiesForURL:[NSURL URLWithString:@"https://facebook.com/"]];
            
            for (NSHTTPCookie* cookie in facebookCookies) {
                [cookies deleteCookie:cookie];
            }*/
            
            
            NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray* facebookCookies = [cookies cookiesForURL:[NSURL URLWithString:@"https://login.facebook.com"]];
            
            for (NSHTTPCookie* cookie in facebookCookies) {
                [cookies deleteCookie:cookie];
            }
            
            for (NSHTTPCookie *_cookie in cookies.cookies)
            {
                NSRange domainRange = [[_cookie domain] rangeOfString:@"facebook"];
                if(domainRange.length > 0){
                    [cookies deleteCookie:_cookie];
                }
            }
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
        }
        case 2: {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            UIView *menuView = [self.navigationController.view viewWithTag:100];
            menuView.center = CGPointMake(-160, menuView.center.y);
            [self addNote];
            break;
        }
        case 4:{
            UIView *menuView = [self.navigationController.view viewWithTag:100];
            [menuView removeFromSuperview];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        default:
            break;
    }
}


@end
