//
//  LayoutProvider.m
//  Notes
//
//  Created by Nemetschek A-Team on 3/31/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "LayoutProvider.h"
#import "Defines.h"
#import "DateTimeManager.h"

@interface LayoutProvider()
@property DateTimeManager *dateTimeManager;
@end

static LayoutProvider *sharedInstance = nil;
static dispatch_once_t predicate = 0;

@implementation LayoutProvider

+ (id)sharedInstance
{
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] initFirstTime];
    });
    
    return sharedInstance;
}

- (id)initFirstTime {
    self = [super init];
    if (self) {
        self.dateTimeManager = [[DateTimeManager alloc] init];
    }
    return self;
}

- (UIBarButtonItem *)setupLeftBarButton:(id)target withSelector:(SEL)selector;
{
    UIButton *leftBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTONS_WIDTH, BUTTONS_HEIGHT)];
    [leftBarButton setBackgroundImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
    [leftBarButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
}

- (UIBarButtonItem *)setupRightBarButton:(id)target withSelector:(SEL)selector;
{
    UIButton *rightBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTONS_WIDTH, BUTTONS_HEIGHT)];
    [rightBarButton setBackgroundImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
    [rightBarButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
}

- (TableViewCell *)getNewTableViewCell:(UITableView *)tableView withNote:(Note *)note
{
    TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:TABLEVIEW_CELL_ID];
    [cell setupWithNote:note];
    return cell;
}

- (UITableViewCell *)getNewCell:(UITableView *)tableView withNote:(Note *)note
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NOTE_CELL_ID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:NOTE_CELL_ID];
    }
    
    cell.textLabel.text = note.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",note.dateCreated];
    return cell;
}

- (UITableViewCell *)getNewCell:(UITableView *)tableView withNotebook:(Notebook *)notebook
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NOTEBOOK_CELL_ID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NOTEBOOK_CELL_ID];
    }
    
    cell.textLabel.text = notebook.name;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu items",(unsigned long)[notebook.notes count]];
    return cell;
}

- (UITableViewCell *)getNewCell:(UITableView *)tableView withReminder:(Reminder *)reminder
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:REMINDER_CELL_ID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:REMINDER_CELL_ID];
    }
    
    cell.textLabel.text = reminder.name;
    cell.detailTextLabel.text = [self.dateTimeManager convertToRelativeDate:reminder.triggerDate];
    return cell;
}

@end
