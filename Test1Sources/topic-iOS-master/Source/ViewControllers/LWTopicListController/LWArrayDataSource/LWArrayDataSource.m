//
//  Created by Lukas K on 04.07.14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

#import "LWArrayDataSource.h"

@interface LWArrayDataSource ()

@property(nonatomic, copy) NSString *cellIdentifier;
@property(nonatomic, copy) TableViewCellConfigureBlock configureCellBlock;

@end

@implementation LWArrayDataSource

- (instancetype)init
{
    return nil;
}

- (instancetype)initWithItems:(NSArray *)anItems
               cellIdentifier:(NSString *)aCellIdentifier
           configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock
{
    self = [super init];
    
    if (self)
    {
        [self setItems:anItems];
        [self setCellIdentifier:aCellIdentifier];
        [self setConfigureCellBlock:aConfigureCellBlock];
    }
    
    return self;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return _items[[indexPath row]];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier forIndexPath:indexPath];
    
    id item = [self itemAtIndexPath:indexPath];
    
    _configureCellBlock(cell, item);
    
    return cell;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
    
    id item = [self itemAtIndexPath:indexPath];
    
    _configureCellBlock(cell, item);
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

@end