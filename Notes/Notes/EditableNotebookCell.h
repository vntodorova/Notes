//
//  EditableNotebookCell.h
//  Notes
//
//  Created by Nemetschek A-Team on 4/18/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@interface EditableNotebookCell : UITableViewCell
@property (nonatomic, weak) id <EditableCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
- (IBAction)deleteButtonClicked:(id)sender;
- (IBAction)editButtonClicked:(id)sender;

@end
