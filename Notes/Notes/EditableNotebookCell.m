//
//  EditableNotebookCell.m
//  Notes
//
//  Created by Nemetschek A-Team on 4/18/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "EditableNotebookCell.h"

@implementation EditableNotebookCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteButtonClicked:(id)sender
{
    [self.delegate deleteButtonClickedOnCell:self];
}

- (IBAction)editButtonClicked:(id)sender
{
    [self.delegate editButtonClickedOnCell:self];
}
@end
