//
//  LWTopicListController.m
//  topic
//
//  Created by Lukas K on 04.07.14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

#import "LWTopicListController.h"
#import "LWArrayDataSource.h"
#import "LWDatabaseGateway.h"
#import "LWTopic.h"
#import "LWServerGateway.h"
#import "LWTopicDetailViewController.h"

@interface LWTopicListController ()<UITableViewDelegate>

@property(nonatomic, strong) LWArrayDataSource *dataSource;

@end

@implementation LWTopicListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navigationItem] setHidesBackButton:YES]; //Don't allow going back to the login screen
    [[self tableView] setDelegate:self];
    [[self refreshControl] addTarget:self action:@selector(refreshTopics:) forControlEvents:UIControlEventValueChanged];
    
    [self setDataSource:[[LWArrayDataSource alloc] initWithItems:nil
                                                  cellIdentifier:@"topicCell"
                                              configureCellBlock:^(UITableViewCell *cell, LWTopic *item)
                         {
                             [[cell textLabel] setText:[item name]];
                             [[cell detailTextLabel] setText:[item percentageString]];
                         }]];
    [[self tableView] setDataSource:[self dataSource]];
    
    [self reloadTableView];
}

- (void)refreshTopics:(id)refreshTopics
{
    [[LWServerGateway instance] syncWithBackend];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateTopics:) name:kSyncCompleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailUpdating:) name:kSyncFailed object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadTableView
{
    [[self refreshControl] beginRefreshing];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
    {
        NSArray *topics = [LWDatabaseGateway fetchAllTopics];
        [_dataSource setItems:topics];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [[self tableView] reloadData];
            [[self refreshControl] endRefreshing];
        });
    });
}

- (void)didUpdateTopics:(NSNotification *)notification
{
    [self reloadTableView];
//    [[self refreshControl] endRefreshing];
}

- (void)didFailUpdating:(NSNotification *)notification
{
    [[self refreshControl] endRefreshing];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LWTopic *selectedTopic = [_dataSource itemAtIndexPath:indexPath];
    LWTopicDetailViewController *viewController = [[self storyboard] instantiateViewControllerWithIdentifier:NSStringFromClass([LWTopicDetailViewController class])];
    [viewController setTopic:selectedTopic];
    [[self navigationController] pushViewController:viewController animated:YES];
}

@end
