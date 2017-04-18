//
//  NotebookCell.m
//  Notes
//
//  Created by Nemetschek A-Team on 4/18/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "NotebookCell.h"

@implementation NotebookCell
@synthesize imageView = _imageView;
@synthesize nameLabel = _nameLabel;
@synthesize detailsLabel = _detailsLabel;

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setSelected:(BOOL)selected
{
}

@end
