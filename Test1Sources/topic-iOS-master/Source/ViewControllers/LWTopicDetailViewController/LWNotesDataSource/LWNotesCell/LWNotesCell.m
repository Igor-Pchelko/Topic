//
//  LWNotesCell.m
//  topic
//
//  Created by Admin on 7/23/14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWNotesCell.h"
#import "LWNote.h"
#import "NSDate+ServerGateway.h"
#import "LWTopicDetailViewController.h"

@interface LWNotesCell ()

@end

@implementation LWNotesCell

- (void)setNote:(LWNote *)note
{
    if (_note != note)
    {
        _note = note;
        _nameTextField.delegate = self;
        _descTextField.delegate = self;

        [_dateLabel setText:([_note date] ? [NSDate apiStringFromDateWithoutSeconds:[_note date]] : nil)];

        _btnCancel.hidden = TRUE;
        _btnSave.hidden = TRUE;
        _nameTextField.hidden = TRUE;
        _descTextField.hidden = TRUE;
        [_nameLabel setText:[_note name]];
        [_descriptionLabel setText:[_note description]];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editNote)];
        [recognizer setNumberOfTapsRequired:1];
        [recognizer setNumberOfTouchesRequired:1];
        [_noteView addGestureRecognizer:recognizer];
    }
}

-(void)editNote
{
    [self.controler editNote:self.note];
}

- (void)setToTheRight:(BOOL)toTheRight
{
    if (_toTheRight != toTheRight)
    {
        _toTheRight = toTheRight;
    }
    
    [self layoutIfNeeded];
}

- (void)layoutSubviews
{
    CGRect frame = [_noteView frame];
    frame.origin.x = _toTheRight ? ([self frame].size.width - frame.size.width) : .0f;
    [_noteView setFrame:frame];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self setNote:nil];
    
    _toTheRight = NO;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


@end
