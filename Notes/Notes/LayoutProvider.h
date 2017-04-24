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

- (UIBarButtonItem *)setupLeftBarButton:(id)target action:(SEL)action;
- (UIBarButtonItem *)setupRightBarButton:(id)target action:(SEL)action;

- (UIView *)confirmationViewFor:(id)target firstAction:(SEL)action1 secondAction:(SEL)action2 frame:(CGRect)frame;

- (UIView *)notebookHeaderWithAction:(SEL)action target:(id)target editingMode:(BOOL)editingMode;
- (UIView *)remindersHeader;

- (TableViewCell *)newTableViewCell:(UITableView *)tableView note:(Note *)note delegate:(id)delegate;
- (UITableViewCell *)searchResultCellWithNote:(Note *)note notebook:(Notebook *)notebook;

- (EditableNotebookCell *)newEditableCell:(UITableView *)tableView notebook:(Notebook *)notebook delegate:(id)delegate;
- (NotebookCell *)newCell:(UITableView *)tableView notebook:(Notebook *)notebook notebookSize:(NSInteger)size;
- (UITableViewCell *)newCell:(UITableView *)tableView reminder:(Reminder *)reminder;

- (UIBarButtonItem *)saveBarButtonWithAction:(SEL)action target:(id)target;
- (UIBarButtonItem *)settingsBarButtonWithAction:(SEL)action target:(id)target;
- (UIBarButtonItem *)eraserBarButtonWithAction:(SEL)action target:(id)target;
- (UIBarButtonItem *)penBarButtonWithAction:(SEL)action target:(id)target;
- (UIBarButtonItem *)colorPickerBarButtonWithAction:(SEL)action target:(id)target;

@property CGSize screenSize;

@end
