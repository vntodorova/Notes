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
#import "ThemeManager.h"

@interface LayoutProvider()
@property DateTimeManager *dateTimeManager;
@property ThemeManager *themeManager;
@end

static LayoutProvider *sharedInstance = nil;

@implementation LayoutProvider

+ (id)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[self alloc] initFirstTime];
    }
    return sharedInstance;
}

- (id)initFirstTime {
    self = [super init];
    if (self) {
        self.dateTimeManager = [[DateTimeManager alloc] init];
        self.themeManager = [ThemeManager sharedInstance];
    }
    return self;
}

#pragma mark -
#pragma mark Navigation controller

- (UIBarButtonItem *)setupLeftBarButton:(id)target withSelector:(SEL)selector;
{
    return [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:target action:selector];
}

- (UIBarButtonItem *)setupRightBarButton:(id)target withSelector:(SEL)selector;
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:target action:selector];
}

#pragma mark -
#pragma mark Main ViewController

- (TableViewCell *)getNewTableViewCell:(UITableView *)tableView withNote:(Note *)note
{
    TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:TABLEVIEW_CELL_ID];
    cell.nameLabel.text = note.name;
    cell.infoLabel.text = note.dateCreated;
    cell.cellNote = note;
    cell.nameLabel.textColor = [self.themeManager.styles objectForKey:TEXT_COLOR];
    cell.infoLabel.textColor = [self.themeManager.styles objectForKey:TEXT_COLOR];
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds = YES;
    cell.backgroundColor = [self.themeManager.styles objectForKey:TABLEVIEW_CELL_COLOR];
    return cell;
}

#pragma mark -
#pragma mark LeftPanelViewController

- (UITableViewCell *)getNewCell:(UITableView *)tableView withNote:(Note *)note
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NOTE_CELL_ID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:NOTE_CELL_ID];
    }
    cell.backgroundColor = [self.themeManager.styles objectForKey:TABLEVIEW_CELL_COLOR];
    cell.textLabel.text = note.name;
    cell.textLabel.textColor = [self.themeManager.styles objectForKey:TEXT_COLOR];
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
    cell.backgroundColor = [self.themeManager.styles objectForKey:TABLEVIEW_CELL_COLOR];
    cell.textLabel.text = notebook.name;
    cell.textLabel.textColor = [self.themeManager.styles objectForKey:TEXT_COLOR];
    //TODO cell.detailTextLabel.text = Notebook's notes count
    return cell;
}

- (UITableViewCell *)getNewCell:(UITableView *)tableView withReminder:(Reminder *)reminder
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:REMINDER_CELL_ID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:REMINDER_CELL_ID];
    }
    cell.backgroundColor = [self.themeManager.styles objectForKey:TABLEVIEW_CELL_COLOR];
    cell.textLabel.text = reminder.name;
    cell.textLabel.textColor = [self.themeManager.styles objectForKey:TEXT_COLOR];
    cell.detailTextLabel.text = [self.dateTimeManager convertToRelativeDate:reminder.triggerDate];
    return cell;
}

@end
