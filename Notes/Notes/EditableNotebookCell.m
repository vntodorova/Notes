//
//  EditableNotebookCell.m
//  Notes
//
//  Created by Nemetschek A-Team on 4/18/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "EditableNotebookCell.h"
#import "ThemeManager.h"
#import "Defines.h"
#import "Notebook.h"

@implementation EditableNotebookCell

- (void)setupWithNotebook:(Notebook *)notebook
{
    self.isEditing = NO;
    self.backgroundColor = [[ThemeManager sharedInstance].styles objectForKey:TABLEVIEW_CELL_COLOR];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    [self.nameLabel setUserInteractionEnabled:NO];
    [self.editButton setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
    self.nameLabel.text = notebook.name;
    self.nameLabel.textColor = [[ThemeManager sharedInstance].styles objectForKey:TINT];
}

- (IBAction)deleteButtonClicked:(id)sender
{
    [self.delegate deleteButtonClickedOnCell:self];
}

- (IBAction)editButtonClicked:(id)sender
{
    if(self.isEditing)
    {
        if(![self.nameBeforeEditing isEqualToString:self.nameLabel.text])
        {
            [self.delegate onCellNameChanged:self];
        }
        [self exitNameEditingMode];
    }
    else
    {
        [self enterNameEditingMode];
    }
}

- (void)exitNameEditingMode
{
    self.isEditing = NO;
    [self.nameLabel setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.3 animations:^{
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        [self.editButton setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
    }];
}

- (void)enterNameEditingMode
{
    self.isEditing = YES;
    self.nameBeforeEditing = self.nameLabel.text;
    [self.nameLabel setUserInteractionEnabled:YES];
    [UIView animateWithDuration:0.3 animations:^{
        [self.nameLabel setBackgroundColor:[UIColor whiteColor]];
        [self.editButton setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
    }];
}

@end
