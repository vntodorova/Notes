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

- (TableViewCell *)getNewTableViewCell:(UITableView *)tableView withNote:(Note *)note andDelegate:(id)delegate;
{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLEVIEW_CELL_ID];
    cell.delegate = delegate;
    cell.nameLabel.text = note.name;
    cell.tableView = tableView;
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

- (UIView *)getConfirmationViewFor:(id)target firstAction:(SEL)action1 secondAction:(SEL)action2 frame:(CGRect)frame
{
    UIView *confirmationView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - SMALL_MARGIN)];
    [confirmationView setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:95.0/255.0 blue:95.0/255.0 alpha:1.0]];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, frame.size.width, frame.size.height)];
    [title setTextColor:[UIColor blackColor]];
    [title setText:@"Confirm"];
    
    UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake(180, MARGIN, BUTTONS_WIDTH, BUTTONS_WIDTH)];
    [okButton setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
    [okButton addTarget:target action:action1 forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(210, MARGIN, BUTTONS_WIDTH, BUTTONS_WIDTH)];
    [cancelButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [cancelButton addTarget:target action:action2 forControlEvents:UIControlEventTouchUpInside];
    
    [confirmationView addSubview:title];
    [confirmationView addSubview:okButton];
    [confirmationView addSubview:cancelButton];
    return confirmationView;
}

- (UIButton *)getHeaderButtonWithAction:(SEL)selector andTarget:(id)target
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(HEADER_WIDTH - HEADER_HEIGHT, 0, HEADER_HEIGHT, HEADER_HEIGHT)];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIView *)getNotebookHeaderWithAction:(SEL)action target:(id)target editingMode:(BOOL)editingMode
{
    CGRect headerFrame = CGRectMake(0, 0, HEADER_WIDTH, HEADER_HEIGHT);
    UIView *headerView = [[UIView alloc] initWithFrame: headerFrame];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame: headerFrame];
    [headerTitle setTextColor:[self.themeManager.styles objectForKey:TINT]];
    [headerView addSubview:headerTitle];
    [headerTitle setText:NOTEBOOK_SECTION_NAME];
    UIButton *button = [self getHeaderButtonWithAction:action andTarget:target];
    
    if(editingMode)
    {
        [button setImage:[UIImage imageNamed:CLOSE_IMAGE] forState:UIControlStateNormal];
    }
    else
    {
        [button setTitle:EDIT_BUTTON_NAME forState:UIControlStateNormal];
    }
    
    [button setTitle:EDIT_BUTTON_NAME forState:UIControlStateNormal];
    [headerView addSubview:button];
    return headerView;
}

- (UIView *)getRemindersHeader
{
    CGRect headerFrame = CGRectMake(0, 0, HEADER_WIDTH, HEADER_HEIGHT);
    UIView *headerView = [[UIView alloc] initWithFrame: headerFrame];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame: headerFrame];
    [headerTitle setTextColor:[self.themeManager.styles objectForKey:TINT]];
    [headerView addSubview:headerTitle];
    [headerTitle setText:REMINDERS_SECTION_NAME];
    return headerView;
}

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
    cell.detailsLabel.textColor = [self.themeManager.styles objectForKey:TINT];
    return cell;
}

- (UITableViewCell *)getNewCell:(UITableView *)tableView withReminder:(Note *)note
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:REMINDER_CELL_ID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:REMINDER_CELL_ID];
    }
    cell.backgroundColor = [self.themeManager.styles objectForKey:TABLEVIEW_CELL_COLOR];
    cell.textLabel.text = note.name;
    cell.textLabel.textColor = [self.themeManager.styles objectForKey:TINT];
    cell.detailTextLabel.text = [self.dateTimeManager convertToRelativeDate:note.triggerDate];
    cell.detailTextLabel.textColor = [self.themeManager.styles objectForKey:TINT];
    return cell;
}

@end
