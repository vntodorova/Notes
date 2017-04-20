//
//  EditableNotebookCell.m
//  Notes
//
//  Created by Nemetschek A-Team on 4/18/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "EditableNotebookCell.h"

@implementation EditableNotebookCell

- (IBAction)deleteButtonClicked:(id)sender
{
    [self.delegate deleteButtonClickedOnCell:self];
}

- (IBAction)editButtonClicked:(id)sender
{
    if(self.isEditing)
    {
        self.isEditing = NO;
        if(![self.nameBeforeEditing isEqualToString:self.nameLabel.text])
        {
            [self.delegate onCellNameChanged:self];
        }
        [self.nameLabel setUserInteractionEnabled:NO];
        [UIView animateWithDuration:0.3 animations:^{
            [self.nameLabel setBackgroundColor:[UIColor clearColor]];
            [self.editButton setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
        }];
    }
    else
    {
        self.isEditing = YES;
        self.nameBeforeEditing = self.nameLabel.text;
        [self.nameLabel setUserInteractionEnabled:YES];
        [UIView animateWithDuration:0.3 animations:^{
            [self.nameLabel setBackgroundColor:[UIColor whiteColor]];
            [self.editButton setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        }];
    }
}
@end
