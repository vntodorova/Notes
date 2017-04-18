//
//  LayoutProvider.h
//  Notes
//
//  Created by Nemetschek A-Team on 3/31/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TableViewCell;
@class Note;
@class Notebook;
@class Reminder;
@class NotebookCell;
@class EditableNotebookCell;

@interface LayoutProvider : NSObject

+ (id)sharedInstance;
- (id)init NS_UNAVAILABLE;

- (UIBarButtonItem *)setupLeftBarButton:(id)target withSelector:(SEL)selector;
- (UIBarButtonItem *)setupRightBarButton:(id)target withSelector:(SEL)selector;

- (TableViewCell *)getNewTableViewCell:(UITableView *)tableView withNote:(Note *)note;

- (EditableNotebookCell *)getNewEditableCell:(UITableView *)tableView withNotebook:(Notebook *)notebook;
- (NotebookCell *)getNewCell:(UITableView *)tableView withNotebook:(Notebook *)notebook andNotebookSize:(NSInteger)size;
- (UITableViewCell *)getNewCell:(UITableView *)tableView withReminder:(Reminder *)reminder;

@end
