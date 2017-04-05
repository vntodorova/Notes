//
//  LayoutProvider.h
//  Notes
//
//  Created by Nemetschek A-Team on 3/31/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableViewCell.h"
#import "Note.h"
#import "Notebook.h"
#import "Reminder.h"

@interface LayoutProvider : NSObject

@property UIVisualEffectView *bluredView;

- (TableViewCell *)getNewCell:(UITableView *)tableView withNote:(Note *)note;
- (UIBarButtonItem *)setupLeftBarButton:(id)target withSelector:(SEL)selector;
- (UIBarButtonItem *)setupRightBarButton:(id)target withSelector:(SEL)selector;

- (UITableViewCell *)getNewCell:(UITableView *)tableView withNotebook:(Notebook *)notebook;
- (UITableViewCell *)getNewCell:(UITableView *)tableView withReminder:(Reminder *)reminder;

@end
