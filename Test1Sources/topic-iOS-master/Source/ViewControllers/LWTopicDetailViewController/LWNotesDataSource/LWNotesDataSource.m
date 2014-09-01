//
//  LWNotesDataSource.m
//  topic
//
//  Created by Admin on 7/23/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWNotesDataSource.h"
#import "LWNote.h"
#import "LWNotesCell.h"

@implementation LWNotesDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_notes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LWNotesCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LWNotesCell class]) forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[LWNotesCell alloc] init];
    }
    
    LWNote *note = _notes[[indexPath row]];
    cell.controler = self.controler;
    [cell setNote:note];
    [cell setToTheRight:([indexPath row] % 2 == 0)];
    
    return cell;
}


@end
