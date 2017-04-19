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
@property (nonatomic, strong) LayoutProvider *layoutProvider;
@property (nonatomic, strong) DateTimeManager *dateTimeManager;
@property (nonatomic, strong) ThemeManager *themeManager;

@property BOOL notebookSectionEditing;

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
    //[self testCode];
}

//- (void)testCode
//{
//    //TODO delete
//    Reminder *reminder1 = [[Reminder alloc] init];
//    reminder1.name = @"Wash the car";
//    reminder1.triggerDate = @"13:00:00, 06-04-2018";
//    
//    Reminder *reminder2 = [[Reminder alloc] init];
//    reminder2.name = @"Random reminder name";
//    reminder2.triggerDate = @"13:00:00, 15-05-2017";
//    
//    Reminder *reminder3 = [[Reminder alloc] init];
//    reminder3.name = @"Add Settings button";
//    reminder3.triggerDate = @"13:00:00, 15-06-2017";
//    
//    NSMutableArray *reminders = [[NSMutableArray alloc] initWithObjects:reminder1, reminder2, reminder3, nil];
//    
//    [reminders sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//        Reminder *reminder1 = (Reminder *)obj1;
//        Reminder *reminder2 = (Reminder *)obj2;
//        return [self.dateTimeManager compareStringDate:reminder1.triggerDate andDate:reminder2.triggerDate];
//    }];
//    
//    [self.tableViewDataSource setObject:reminders forKey:REMINDER_KEY];
//    [self.tableView reloadData];
//}

- (void)setup
{
    self.tableViewDataSource = [[NSMutableDictionary alloc] init];
    self.dateTimeManager = [[DateTimeManager alloc] init];
    self.layoutProvider = [LayoutProvider sharedInstance];
    self.themeManager = [ThemeManager sharedInstance];
    
    [self loadTheme];
    [self reloadData];
    
    UIPanGestureRecognizer *panGestureRecogniser = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognised:)];
    [self.view addGestureRecognizer:panGestureRecogniser];
    panGestureRecogniser.delegate = self;
    
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

#pragma mark -
#pragma mark TableView header buttons

- (IBAction)settingsButtonClicked:(UIButton *)sender
{
    [self.delegate showSettings];
}

- (void)editButtonClicked
{
    [self enterEditingMode];
}

- (void)closeButtonClicked
{
    [self exitEditingMode];
}

- (void)exitEditingMode
{
    self.notebookSectionEditing = NO;
    [self.tableView reloadData];
}

- (void)enterEditingMode
{
    self.notebookSectionEditing = YES;
    [self.tableView reloadData];
}

- (void)addCloseButton:(UIView *)headerView
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(headerView.frame.size.width - HEADER_HEIGHT, 0, HEADER_HEIGHT, HEADER_HEIGHT)];
    [button setImage:[UIImage imageNamed:CLOSE_IMAGE] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button];
}

- (void)addEditButton:(UIView *)headerView
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(headerView.frame.size.width - HEADER_HEIGHT, 0, HEADER_HEIGHT, HEADER_HEIGHT)];
    [button setTitle:EDIT_BUTTON_NAME forState:UIControlStateNormal];
    [button addTarget:self action:@selector(editButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button];
}

#pragma mark -
#pragma mark TableView delegates

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if(indexPath.section == NOTEBOOKS_SECTION)
    {
        Notebook *notebook = [[self.tableViewDataSource objectForKey:NOTEBOOK_KEY] objectAtIndex:indexPath.row];
        if(self.notebookSectionEditing && ![notebook.name isEqualToString:GENERAL_NOTEBOOK_NAME])
        {
            cell = [self.layoutProvider getNewEditableCell:tableView withNotebook:notebook andDelegate:self];
        }
        else
        {
            cell = [self.layoutProvider getNewCell:tableView
                                      withNotebook:notebook
                                   andNotebookSize:[[self.noteManager getNoteListForNotebook:notebook] count]];
        }
    }
    
    if(indexPath.section == REMINDERS_SECTION)
    {
        NSMutableArray *reminders = [self.tableViewDataSource objectForKey:REMINDER_KEY];
        cell = [self.layoutProvider getNewCell:tableView withReminder:[reminders objectAtIndex:indexPath.row]];
    }

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    switch (section) {
        case NOTEBOOKS_SECTION:
            numberOfRows = [[self.tableViewDataSource objectForKey:NOTEBOOK_KEY] count];
            break;
        case REMINDERS_SECTION:
            numberOfRows = [[self.tableViewDataSource objectForKey:REMINDER_KEY] count];
            break;
        default:
            break;
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
        [self notebookClickedOnIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, HEADER_HEIGHT)];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, tableView.frame.size.width, HEADER_HEIGHT)];
    [headerTitle setTextColor:[self.themeManager.styles objectForKey:TINT]];
    [headerView addSubview:headerTitle];
    
    switch (section) {
        case NOTEBOOKS_SECTION:
        {
            [headerTitle setText:NOTEBOOK_SECTION_NAME];
            if(!self.notebookSectionEditing)
            {
                [self addEditButton:headerView];
            }
            else
            {
                [self addCloseButton:headerView];
            }
            break;
        }
        case REMINDERS_SECTION:
        {
            [headerTitle setText:REMINDERS_SECTION_NAME];
            break;
        }
        default:
            break;
    }
    
    return headerView;
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
        [self.view setFrame:CGRectMake(offSet,self.view.frame.origin.y, self.view.frame.size.width , self.view.frame.size.height)];
    }
}

- (void)panEnded:(UIPanGestureRecognizer *)pan
{
    [self.delegate hideLeftPanel];
}

#pragma mark -
#pragma mark EditableCell delegate

- (void)deleteButtonClickedOnCell:(EditableNotebookCell *)cell
{
    NSIndexPath *pathForDeleting = [self.tableView indexPathForCell:cell];
    [self.noteManager removeNotebookWithName:cell.nameLabel.text];
    [self.tableViewDataSource setObject:[self.noteManager getNotebookList] forKey:NOTEBOOK_KEY];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:pathForDeleting] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)onCellNameChanged:(EditableNotebookCell *)cell
{
    [self.noteManager renameNotebookWithName:cell.nameBeforeEditing newName:cell.nameLabel.text];
}

@end
