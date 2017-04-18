//
//  LeftPanelViewController.m
//  Notes
//
//  Created by Nemetschek A-Team on 4/3/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "LeftPanelViewController.h"
#import "ViewController.h"
#import "DateTimeManager.h"
#import "Defines.h"
#import "Reminder.h"
#import "LayoutProvider.h"
#import "SettingsPanelViewController.h"
#import "ThemeManager.h"
#import "LocalNoteManager.h"
#import "Notebook.h"
#import "Note.h"
#import "EditableNotebookCell.h"
#import "NotebookCell.h"

@interface LeftPanelViewController()

@property (nonatomic, strong) LocalNoteManager *noteManager;
@property DateTimeManager *dateTimeManager;
@property ThemeManager *themeManager;
@property BOOL editingMode;

@property LayoutProvider *layoutProvider;
@property float pointerStartPanCoordinatesX;
@property float panelStartPanCoordinatesX;
@end

@implementation LeftPanelViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil manager:(LocalNoteManager *)noteManager
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.noteManager = noteManager;
        self.isHidden = YES;
        self.view.frame = CGRectMake(-1 * LEFT_PANEL_WIDTH, 0, LEFT_PANEL_WIDTH, self.view.frame.size.height);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self testCode];
}

- (void)testCode
{
    //TODO delete
    Reminder *reminder1 = [[Reminder alloc] init];
    reminder1.name = @"Wash the car";
    reminder1.triggerDate = @"13:00:00, 06-04-2018";
    
    Reminder *reminder2 = [[Reminder alloc] init];
    reminder2.name = @"Random reminder name";
    reminder2.triggerDate = @"13:00:00, 15-05-2017";
    
    Reminder *reminder3 = [[Reminder alloc] init];
    reminder3.name = @"Add Settings button";
    reminder3.triggerDate = @"13:00:00, 15-06-2017";
    
    NSMutableArray *reminders = [[NSMutableArray alloc] initWithObjects:reminder1, reminder2, reminder3, nil];
    
    [reminders sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Reminder *reminder1 = (Reminder *)obj1;
        Reminder *reminder2 = (Reminder *)obj2;
        return [self.dateTimeManager compareStringDate:reminder1.triggerDate andDate:reminder2.triggerDate];
    }];
    
    [self.tableViewDataSource setObject:[self.noteManager getNotebookList] forKey:NOTEBOOK_KEY];
    [self.tableViewDataSource setObject:reminders forKey:REMINDER_KEY];
    [self.tableView reloadData];
}

- (void)setup
{
    self.dateTimeManager = [[DateTimeManager alloc] init];
    self.layoutProvider = [LayoutProvider sharedInstance];
    self.themeManager = [ThemeManager sharedInstance];
    [self loadTheme];
    [self.facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
    [self.googleButton setBackgroundImage:[UIImage imageNamed:@"google.png"] forState:UIControlStateNormal];
    UIPanGestureRecognizer *panGestureRecogniser = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognised:)];
    [self.view addGestureRecognizer:panGestureRecogniser];
    panGestureRecogniser.delegate = self;
    self.tableViewDataSource = [[NSMutableDictionary alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:NOTEBOOK_CELL_ID bundle:nil] forCellReuseIdentifier:NOTEBOOK_CELL_ID];
    [self.tableView registerNib:[UINib nibWithNibName:EDITABLE_NOTEBOOK_CELL_ID bundle:nil] forCellReuseIdentifier:EDITABLE_NOTEBOOK_CELL_ID];
}

- (void)loadTheme
{
    self.view.backgroundColor = [self.themeManager.styles objectForKey:BACKGROUND_COLOR];
    self.tableView.backgroundColor = [self.themeManager.styles objectForKey:TABLEVIEW_BACKGROUND_COLOR];
    [self.view setTintColor:[self.themeManager.styles objectForKey:TINT]];
    [self.tableView reloadData];
}

- (void)reloadData
{
    [self.tableViewDataSource setObject:[self.noteManager getNotebookList] forKey:NOTEBOOK_KEY];
    [self.tableView reloadData];
}

- (void)notebookClickedOnIndexPath:(NSIndexPath *)indexPath
{
    Notebook *clickedNotebook = [[self.tableViewDataSource objectForKey:NOTEBOOK_KEY] objectAtIndex:indexPath.row];
    [self.delegate changeCurrentNotebook:clickedNotebook.name];
    [self.delegate hideLeftPanel];
}

- (IBAction)settingsButtonClicked:(UIButton *)sender
{
    [self.delegate showSettings];
}

- (void)editButtonClicked
{
    self.editingMode = YES;
    [self.tableView reloadData];
}

- (void)closeButtonClicked
{
    self.editingMode = NO;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark TableView delegates

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if(indexPath.section == NOTEBOOKS_SECTION)
    {
        Notebook *notebook = (Notebook *)[[self.tableViewDataSource objectForKey:NOTEBOOK_KEY] objectAtIndex:indexPath.row];
        if(self.editingMode && ![notebook.name isEqualToString:@"General"])
        {
            cell = [self.layoutProvider getNewEditableCell:tableView withNotebook:notebook];
            EditableNotebookCell *editableCell = (EditableNotebookCell*)cell;
            editableCell.delegate = self;
            cell = editableCell;
        }
        else
        {
            NSInteger notebookSize = [[self.noteManager getNoteListForNotebook:notebook] count];
            cell = [self.layoutProvider getNewCell:tableView withNotebook:notebook andNotebookSize:notebookSize];
        }
    }
    
    if(indexPath.section == REMINDERS_SECTION)
    {
        NSMutableArray *reminders = [self.tableViewDataSource objectForKey:REMINDER_KEY];
        Reminder *reminder = [reminders objectAtIndex:indexPath.row];
        cell = [self.layoutProvider getNewCell:tableView withReminder:reminder];
    }

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if(section == NOTEBOOKS_SECTION)
    {
        numberOfRows = [[self.tableViewDataSource objectForKey:NOTEBOOK_KEY] count];
    }
    if(section == REMINDERS_SECTION)
    {
        numberOfRows = [[self.tableViewDataSource objectForKey:REMINDER_KEY] count];
    }
    return numberOfRows;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.tableViewDataSource allKeys] count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == NOTEBOOKS_SECTION)
    {
        NSObject *object = [[self.tableViewDataSource objectForKey:NOTEBOOK_KEY] objectAtIndex:indexPath.row];
        if([object isKindOfClass:[Notebook class]])
        {
            [self notebookClickedOnIndexPath:indexPath];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, tableView.frame.size.width, 18)];
    if(section == NOTEBOOKS_SECTION)
    {
        [label setText:NOTEBOOK_SECTION_NAME];
        if(!self.editingMode)
        {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(200, 5, 40, 25)];
            [button setTitle:@"Edit" forState:UIControlStateNormal];
            [button setTitleColor:[self.themeManager.styles objectForKey:TINT] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(editButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
        }
        else
        {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(210, 5, 25, 25)];
            [button setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
        }
    }
    if(section == REMINDERS_SECTION)
    {
        [label setText:REMINDERS_SECTION_NAME];
    }
    [label setTextColor:[self.themeManager.styles objectForKey:TINT]];
    
    [view addSubview:label];
    return view;
}

#pragma mark -
#pragma mark Pan gesture recogniser

- (void)panGestureRecognised:(UIPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [self panBegan:pan];
            break;
        case UIGestureRecognizerStateChanged:
            [self panChanged:pan];
            break;
        case UIGestureRecognizerStateEnded:
            [self panEnded:pan];
            break;
        default:
            break;
    }
}

- (void)panBegan:(UIPanGestureRecognizer *)pan
{
    self.pointerStartPanCoordinatesX = [pan locationInView:self.view.window].x;
    self.panelStartPanCoordinatesX = self.view.frame.origin.x;
}

- (void)panChanged:(UIPanGestureRecognizer *)pan
{
    float currentPointerDistance = [pan locationInView:self.view.window].x - self.pointerStartPanCoordinatesX;
    if(currentPointerDistance <= 0)
    {
        CGFloat offSet = self.panelStartPanCoordinatesX + currentPointerDistance;
        self.view.frame = CGRectMake(offSet,self.view.frame.origin.y, self.view.frame.size.width , self.view.frame.size.height);
    }
}

- (void)panEnded:(UIPanGestureRecognizer *)pan
{
    self.editingMode = NO;
    [self.tableView reloadData];
    [self.delegate hideLeftPanel];
}

#pragma mark -
#pragma mark EditableCell delegate

- (void)deleteButtonClickedOnCell:(EditableNotebookCell *)cell
{
    NSIndexPath *pathForDeleting = [self.tableView indexPathForCell:cell];
    [self.noteManager removeNotebookWithName:cell.nameLabel.text];
    [self.tableViewDataSource setObject:[self.noteManager getNotebookList] forKey:NOTEBOOK_KEY];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:pathForDeleting] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)editButtonClickedOnCell:(EditableNotebookCell *)cell
{
    
}

@end
