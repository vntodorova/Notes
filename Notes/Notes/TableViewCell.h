//
//  TableViewCell.h
//  Notes
//
//  Created by Nemetschek A-Team on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "PublicProtocols.h"

@interface TableViewCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (nonatomic, weak) id <TableViewCellDelegate> delegate;
@property Note* cellNote;

@property float pointerStartDragCoordinatesX;
@property float cellStartDragCoordinatesX;

- (void)setupWithNote:(Note *)note;

@end
