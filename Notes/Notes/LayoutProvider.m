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
#import "TableViewCell.h"
#import "Note.h"
#import "Notebook.h"
#import "NotebookCell.h"
#import "EditableNotebookCell.h"

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
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLEVIEW_CELL_ID];
    cell.nameLabel.text = note.name;
    cell.infoLabel.text = note.dateCreated;
    cell.cellNote = note;
    cell.nameLabel.textColor = [self.themeManager.styles objectForKey:TINT];
    cell.infoLabel.textColor = [self.themeManager.styles objectForKey:TINT];
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds = YES;
    cell.backgroundColor = [self.themeManager.styles objectForKey:TABLEVIEW_CELL_COLOR];
    return cell;
}

#pragma mark -
#pragma mark LeftPanelViewController

- (EditableNotebookCell *)getNewEditableCell:(UITableView *)tableView withNotebook:(Notebook *)notebook andDelegate:(id)delegate
{
    EditableNotebookCell *cell = [tableView dequeueReusableCellWithIdentifier:EDITABLE_NOTEBOOK_CELL_ID];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:EDITABLE_NOTEBOOK_CELL_ID owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.backgroundColor = [self.themeManager.styles objectForKey:TABLEVIEW_CELL_COLOR];
    cell.nameLabel.text = notebook.name;
    cell.nameLabel.textColor = [self.themeManager.styles objectForKey:TINT];
    cell.delegate = delegate;
    return cell;
}

- (UITableViewCell *)getNewCell:(UITableView *)tableView withNotebook:(Notebook *)notebook andNotebookSize:(NSInteger)size
{
    NotebookCell *cell = [tableView dequeueReusableCellWithIdentifier:NOTEBOOK_CELL_ID];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:NOTEBOOK_CELL_ID owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.backgroundColor = [self.themeManager.styles objectForKey:TABLEVIEW_CELL_COLOR];
    cell.nameLabel.text = notebook.name;
    cell.nameLabel.textColor = [self.themeManager.styles objectForKey:TINT];
    cell.detailsLabel.text = [NSString stringWithFormat:@"%ld items",size];
    return cell;
}

- (UITableViewCell *)getNewCell:(UITableView *)tableView withReminder:(Note *)note
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:REMINDER_CELL_ID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:REMINDER_CELL_ID];
    }
    cell.backgroundColor = [self.themeManager.styles objectForKey:TABLEVIEW_CELL_COLOR];
    cell.textLabel.text = note.name;
    cell.textLabel.textColor = [self.themeManager.styles objectForKey:TINT];
    cell.detailTextLabel.text = [self.dateTimeManager convertToRelativeDate:note.triggerDate];
    return cell;
}

@end
