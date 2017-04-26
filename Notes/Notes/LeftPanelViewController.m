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
#import "NoteManager.h"
#import "Notebook.h"
#import "Note.h"
#import "EditableNotebookCell.h"
#import "NotebookCell.h"
#import "DropboxNoteManager.h"

@interface LeftPanelViewController()

@property (nonatomic, strong) NoteManager *noteManager;
@property (nonatomic, strong) LayoutProvider *layoutProvider;
@property (nonatomic, strong) DateTimeManager *dateTimeManager;
@property (nonatomic, strong) ThemeManager *themeManager;

@property BOOL sectionEditingMode;
@property EditableNotebookCell *cellForDeleting;
@property UIView *confirmationView;
@property float pointerStartPanCoordinatesX;
@property float panelStartPanCoordinatesX;
@end

@implementation LeftPanelViewController

- (IBAction)onGoogleClick:(id)sender
{

}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil manager:(NoteManager *)noteManager
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.noteManager = noteManager;
        self.tableViewDataSource = [[NSMutableDictionary alloc] init];
        self.dateTimeManager = [[DateTimeManager alloc] init];
        self.layoutProvider = [LayoutProvider sharedInstance];
        self.themeManager = [ThemeManager sharedInstance];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(-1 * LEFT_PANEL_WIDTH, 0, LEFT_PANEL_WIDTH, self.layoutProvider.screenSize.height);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onThemeChanged) name:THEME_CHANGED_EVENT object:nil];
    self.isHidden = YES;

    [self loadTheme];
    [self reloadTableViewData];
    
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

- (void)reloadTableViewData
{
    [self.tableViewDataSource setObject:[self.noteManager getNotebookList] forKey:NOTEBOOK_KEY];
    [self.tableViewDataSource setObject:[self getNotesWithReminders] forKey:REMINDER_KEY];
    [self.tableView reloadData];
}

- (NSArray *)getNotesWithReminders
{
    NSMutableArray *reminders = [[NSMutableArray alloc] init];
    
    for (Notebook *notebook in [self.noteManager getNotebookList])
    {
        for (Note *note in [self.noteManager getNoteListForNotebook:notebook])
        {
            if(note.triggerDate != nil)
            {
                [reminders addObject:note];
            }
        }
    }
    
    [reminders sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
    {
        Note *note1 = (Note *)obj1;
        Note *note2 = (Note *)obj2;
        return [self.dateTimeManager compareStringDate:note1.triggerDate andDate:note2.triggerDate];
    }];
    return reminders;
}

- (void)notebookClickedOnIndexPath:(NSIndexPath *)indexPath
{
    Notebook *clickedNotebook = [[self.tableViewDataSource objectForKey:NOTEBOOK_KEY] objectAtIndex:indexPath.row];
    [self.presentingViewControllerDelegate changeCurrentNotebook:clickedNotebook.name];
    [self.presentingViewControllerDelegate hideLeftPanel];
}

#pragma mark -
#pragma mark TableView header buttons

- (IBAction)settingsButtonClicked:(UIButton *)sender
{
    [self.presentingViewControllerDelegate showSettings];
}

- (void)enterEditingMode
{
    self.sectionEditingMode = YES;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:NOTEBOOKS_SECTION] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)exitEditingMode
{
    [self dismissConfirmationView];
    self.sectionEditingMode = NO;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:NOTEBOOKS_SECTION] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark -
#pragma mark TableView delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if(indexPath.section == NOTEBOOKS_SECTION)
    {
        Notebook *notebook = [[self.tableViewDataSource objectForKey:NOTEBOOK_KEY] objectAtIndex:indexPath.row];
        if(self.sectionEditingMode && ![notebook.name isEqualToString:GENERAL_NOTEBOOK_NAME])
        {
            cell = [self.layoutProvider newEditableCell:tableView notebook:notebook delegate:self];
        }
        else
        {
            cell = [self.layoutProvider newCell:tableView notebook:notebook notebookSize:[[self.noteManager getNoteListForNotebook:notebook] count]];
        }
    }
    
    if(indexPath.section == REMINDERS_SECTION)
    {
        NSMutableArray *reminders = [self.tableViewDataSource objectForKey:REMINDER_KEY];
        cell = [self.layoutProvider newCell:tableView reminder:[reminders objectAtIndex:indexPath.row]];
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case NOTEBOOKS_SECTION:
            return [[self.tableViewDataSource objectForKey:NOTEBOOK_KEY] count];
        case REMINDERS_SECTION:
            return [[self.tableViewDataSource objectForKey:REMINDER_KEY] count];
        default:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.tableViewDataSource allKeys] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header;
    if(section == NOTEBOOKS_SECTION && self.sectionEditingMode)
    {
        header = [self.layoutProvider notebookHeaderWithAction:@selector(exitEditingMode) target:self editingMode:YES];
    }
    if(section == NOTEBOOKS_SECTION && !self.sectionEditingMode)
    {
        header = [self.layoutProvider notebookHeaderWithAction:@selector(enterEditingMode) target:self editingMode:NO];
    }
    if(section == REMINDERS_SECTION)
    {
        header = [self.layoutProvider remindersHeader];
    }
    return header;
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
    [self.presentingViewControllerDelegate hideLeftPanel];
}

#pragma mark -
#pragma mark EditableCell delegate

- (void)deleteButtonClickedOnCell:(EditableNotebookCell *)cell
{
    self.cellForDeleting = cell;
    if([[self.noteManager getNoteListForNotebookWithName:cell.nameLabel.text] count] == 0)
    {
        [self deleteCell];
    }
    else if(self.confirmationView)
    {
        [self moveConfirmationViewToCell:cell];
    }
    else
    {
        [self addConfirmationViewToCell:cell];
    }
}

- (void)onCellNameChanged:(EditableNotebookCell *)cell
{
    [self.noteManager renameNotebookWithName:cell.nameBeforeEditing newName:cell.nameLabel.text];
}

- (void)deleteCell
{
    NSIndexPath *pathForDeleting = [self.tableView indexPathForCell:self.cellForDeleting];
    [self.noteManager removeNotebookWithName:self.cellForDeleting.nameLabel.text];
    [self.tableViewDataSource setObject:[self.noteManager getNotebookList] forKey:NOTEBOOK_KEY];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:pathForDeleting] withRowAnimation:UITableViewRowAnimationTop];
    [self dismissConfirmationView];
    [self.presentingViewControllerDelegate changeCurrentNotebook:GENERAL_NOTEBOOK_NAME];
}

- (void)dismissConfirmationView
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.confirmationView setAlpha:0];
    } completion:^(BOOL finished) {
        [self.confirmationView setHidden:YES];
    }];
}

- (void)moveConfirmationViewToCell:(EditableNotebookCell *)cell
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.confirmationView setAlpha:0];
    } completion:^(BOOL finished) {
        [self.confirmationView setHidden:NO];
        [self.confirmationView setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height - SMALL_MARGIN)];
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self.confirmationView setAlpha:1];
    }];
}

- (void)addConfirmationViewToCell:(EditableNotebookCell *)cell
{
    self.confirmationView = [self.layoutProvider confirmationViewFor:self firstAction:@selector(deleteCell) secondAction:@selector(dismissConfirmationView) frame:cell.frame];
    [self.confirmationView setAlpha:0];
    [self.confirmationView setHidden:NO];
    [self.tableView addSubview:self.confirmationView];
    [UIView animateWithDuration:0.3 animations:^{
        [self.confirmationView setAlpha:1];
    }];
}

#pragma mark -
#pragma mark Notification handlers

- (void)onThemeChanged
{
    [self loadTheme];
}

@end
