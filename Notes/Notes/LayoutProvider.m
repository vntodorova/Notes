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

#define LEFT_BARBUTTON_TITLE                @"Menu"
#define BARBUTTON_SETTINGS_IMAGE_NAME       @"settings"
#define BARBUTTON_ERASER_IMAGE_NAME         @"eraser"
#define BARBUTTON_PEN_IMAGE_NAME            @"pen"
#define BARBUTTON_COLORPICKER_IMAGE_NAME    @"colorPicker"

@interface LayoutProvider()
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
        self.themeManager = [ThemeManager sharedInstance];
        self.screenSize = [UIScreen mainScreen].bounds.size;
    }
    return self;
}

#pragma mark -
#pragma mark Navigation controller

- (UIBarButtonItem *)setupLeftBarButton:(id)target action:(SEL)action;
{
    return [[UIBarButtonItem alloc] initWithTitle:LEFT_BARBUTTON_TITLE style:UIBarButtonItemStylePlain target:target action:action];
}

- (UIBarButtonItem *)setupRightBarButton:(id)target action:(SEL)action;
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:target action:action];
}

#pragma mark -
#pragma mark Main ViewController

- (TableViewCell *)newTableViewCell:(UITableView *)tableView note:(Note *)note delegate:(id)delegate;
{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLEVIEW_CELL_ID];
    cell.delegate = delegate;
    cell.nameLabel.text = note.name;
    cell.tableView = tableView;
    cell.infoLabel.text = note.dateModified;
    cell.cellNote = note;
    cell.nameLabel.textColor = [self.themeManager.styles objectForKey:TINT];
    cell.infoLabel.textColor = [self.themeManager.styles objectForKey:TINT];
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds = YES;
    cell.backgroundColor = [self.themeManager.styles objectForKey:TABLEVIEW_CELL_COLOR];
    return cell;
}

- (UITableViewCell *)searchResultCellWithNote:(Note *)note notebook:(Notebook *)notebook;
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SEARCH_RESULT_CELL_ID];
    cell.textLabel.text = note.name;
    cell.detailTextLabel.text = notebook.name;
    cell.textLabel.textColor = [self.themeManager.styles objectForKey:TINT];
    cell.detailTextLabel.textColor = [self.themeManager.styles objectForKey:TINT];
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds = YES;
    cell.backgroundColor = [self.themeManager.styles objectForKey:TABLEVIEW_CELL_COLOR];
    return cell;
}

#pragma mark -
#pragma mark LeftPanelViewController

- (UIView *)confirmationViewFor:(id)target firstAction:(SEL)action1 secondAction:(SEL)action2 frame:(CGRect)frame
{
    UIView *confirmationView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - SMALL_MARGIN)];
    [confirmationView setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:95.0/255.0 blue:95.0/255.0 alpha:1.0]];
    
    UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake(180, MARGIN, BUTTONS_WIDTH, BUTTONS_WIDTH)];
    [okButton setImage:[UIImage imageNamed:CHECK_IMAGE_NAME] forState:UIControlStateNormal];
    [okButton addTarget:target action:action1 forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(210, MARGIN, BUTTONS_WIDTH, BUTTONS_WIDTH)];
    [cancelButton setImage:[UIImage imageNamed:CLOSE_IMAGE] forState:UIControlStateNormal];
    [cancelButton addTarget:target action:action2 forControlEvents:UIControlEventTouchUpInside];
    
    [confirmationView addSubview:[self getTitleForConfrimationViewinFrame:frame]];
    [confirmationView addSubview:okButton];
    [confirmationView addSubview:cancelButton];
    return confirmationView;
}

- (UILabel*)getTitleForConfrimationViewinFrame:(CGRect)frame
{
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, frame.size.width, frame.size.height)];
    [title setTextColor:[UIColor blackColor]];
    [title setText:CONFRIM_TITLE];
    return title;
}

- (UIButton *)headerButtonWithAction:(SEL)selector target:(id)target
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(HEADER_WIDTH - HEADER_HEIGHT, 0, HEADER_HEIGHT, HEADER_HEIGHT)];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIView *)notebookHeaderWithAction:(SEL)action target:(id)target editingMode:(BOOL)editingMode
{
    CGRect headerFrame = CGRectMake(0, 0, HEADER_WIDTH, HEADER_HEIGHT);
    UIView *headerView = [[UIView alloc] initWithFrame: headerFrame];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame: headerFrame];
    [headerTitle setTextColor:[self.themeManager.styles objectForKey:TINT]];
    [headerView addSubview:headerTitle];
    [headerTitle setText:NOTEBOOK_SECTION_NAME];
    UIButton *button = [self headerButtonWithAction:action target:target];
    
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

- (UIView *)remindersHeader
{
    CGRect headerFrame = CGRectMake(0, 0, HEADER_WIDTH, HEADER_HEIGHT);
    UIView *headerView = [[UIView alloc] initWithFrame: headerFrame];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame: headerFrame];
    [headerTitle setTextColor:[self.themeManager.styles objectForKey:TINT]];
    [headerView addSubview:headerTitle];
    [headerTitle setText:REMINDERS_SECTION_NAME];
    return headerView;
}

- (EditableNotebookCell *)newEditableCell:(UITableView *)tableView notebook:(Notebook *)notebook delegate:(id)delegate
{
    EditableNotebookCell *cell = [tableView dequeueReusableCellWithIdentifier:EDITABLE_NOTEBOOK_CELL_ID];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:EDITABLE_NOTEBOOK_CELL_ID owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setupWithNotebook:notebook];
    cell.delegate = delegate;
    return cell;
}

- (UITableViewCell *)newCell:(UITableView *)tableView notebook:(Notebook *)notebook notebookSize:(NSInteger)size
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
    cell.detailsLabel.text = [NSString stringWithFormat:@"%ld items",(long)size];
    cell.detailsLabel.textColor = [self.themeManager.styles objectForKey:TINT];
    return cell;
}

- (UITableViewCell *)newCell:(UITableView *)tableView reminder:(Note *)note
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:REMINDER_CELL_ID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:REMINDER_CELL_ID];
    }
    cell.backgroundColor = [self.themeManager.styles objectForKey:TABLEVIEW_CELL_COLOR];
    cell.textLabel.text = note.name;
    cell.textLabel.textColor = [self.themeManager.styles objectForKey:TINT];
    cell.detailTextLabel.text = [[DateTimeManager sharedInstance] convertToRelativeDate:note.triggerDate];
    cell.detailTextLabel.textColor = [self.themeManager.styles objectForKey:TINT];
    return cell;
}

#pragma mark -
#pragma mark DrawingViewController

- (UIButton *)buttonWithImageName:(NSString *)imageName action:(SEL)action target:(id)target
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(0, 0, BUTTONS_WIDTH, BUTTONS_HEIGHT)];
    [button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIBarButtonItem *)saveBarButtonWithAction:(SEL)action target:(id)target
{
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    saveButton.frame = CGRectMake(0, 0, 40, BUTTONS_HEIGHT);
    return [[UIBarButtonItem alloc] initWithCustomView:saveButton];
}

- (UIBarButtonItem *)settingsBarButtonWithAction:(SEL)action target:(id)target
{
    return [[UIBarButtonItem alloc] initWithCustomView:[self buttonWithImageName:@"settings" action:action target:target]];
}

- (UIBarButtonItem *)eraserBarButtonWithAction:(SEL)action target:(id)target
{
    return [[UIBarButtonItem alloc] initWithCustomView:[self buttonWithImageName:@"eraser" action:action target:target]];
}

- (UIBarButtonItem *)penBarButtonWithAction:(SEL)action target:(id)target
{
    return [[UIBarButtonItem alloc] initWithCustomView:[self buttonWithImageName:@"pen" action:action target:target]];
}

- (UIBarButtonItem *)colorPickerBarButtonWithAction:(SEL)action target:(id)target
{
    return [[UIBarButtonItem alloc] initWithCustomView:[self buttonWithImageName:@"colorPicker" action:action target:target]];
}

@end
