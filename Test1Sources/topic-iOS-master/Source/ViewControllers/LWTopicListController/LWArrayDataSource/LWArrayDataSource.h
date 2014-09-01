//
//  Created by Lukas K on 04.07.14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

typedef void (^TableViewCellConfigureBlock)(id cell, id item);

@interface LWArrayDataSource : NSObject <UITableViewDataSource, UICollectionViewDataSource>

@property(nonatomic, copy) NSArray *items;

- (instancetype)initWithItems:(NSArray *)anItems
               cellIdentifier:(NSString *)aCellIdentifier
           configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock;
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end