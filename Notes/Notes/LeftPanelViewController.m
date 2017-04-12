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

@interface LeftPanelViewController()

@property (nonatomic, strong) LocalNoteManager *noteManager;
@property DateTimeManager *dateTimeManager;
@property ThemeManager *themeManager;

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
    self.notebooksClicked = [[NSMutableDictionary alloc] init];
}

- (void)loadTheme
{
    self.view.backgroundColor = [self.themeManager.styles objectForKey:BACKGROUND_COLOR];
    self.tableView.backgroundColor = [self.themeManager.styles objectForKey:TABLEVIEW_BACKGROUND_COLOR];
    [self.view setTintColor:[self.themeManager.styles objectForKey:TEXT_COLOR]];
    [self.tableView reloadData];
}

- (void)notebookClickedOnIndexPath:(NSIndexPath *)indexPath
{
    NSString *clickedNotebookName = [[[self.tableViewDataSource objectForKey:NOTEBOOK_KEY] objectAtIndex:indexPath.row] name];
    NSNumber *isClicked = [self.notebooksClicked valueForKey:clickedNotebookName];
    
    if([isClicked boolValue])
    {
        [self hideNotebookContents:indexPath];
        [self.notebooksClicked setValue:[NSNumber numberWithBool:NO] forKey:clickedNotebookName];
        
    }
    if(![isClicked boolValue])
    {
        [self showNotebookContents:indexPath];
        [self.notebooksClicked setValue:[NSNumber numberWithBool:YES] forKey:clickedNotebookName];
    }
}

- (void)showNotebookContents:(NSIndexPath *)indexPath
{
    NSArray *notes = [self.noteManager getNoteListForNotebook:[[self.tableViewDataSource objectForKey:NOTEBOOK_KEY] objectAtIndex:indexPath.row]];
    NSInteger indexToAdd = indexPath.row + 1;
    NSMutableArray *notebooks = [self.tableViewDataSource objectForKey:NOTEBOOK_KEY];
    
    [self.tableView beginUpdates];
    for (Note* currentNote in notes)
    {
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexToAdd inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationTop];
        [notebooks insertObject:currentNote atIndex:indexToAdd];
        indexToAdd ++;
    }
    [self.tableView endUpdates];
}

- (void)hideNotebookContents:(NSIndexPath *)indexPath
{
    NSArray *notes = [self.noteManager getNoteListForNotebook:[[self.tableViewDataSource objectForKey:NOTEBOOK_KEY] objectAtIndex:indexPath.row]];
    NSInteger indexToRemove = indexPath.row + 1;
    NSMutableArray *notebooks = [self.tableViewDataSource objectForKey:NOTEBOOK_KEY];

    [self.tableView beginUpdates];
    for (Note* currentNote in notes)
    {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexToRemove inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationTop];
        [notebooks removeObject:currentNote];
        indexToRemove ++;
    }
    [self.tableView endUpdates];
}

- (IBAction)settingsButtonClicked:(UIButton *)sender
{
    [self.delegate showSettings];
}

#pragma mark -
#pragma mark TableView delegates

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if(indexPath.section == NOTEBOOKS_SECTION)
    {
        NSObject *object = [[self.tableViewDataSource objectForKey:NOTEBOOK_KEY] objectAtIndex:indexPath.row];
        
        if([object isKindOfClass:[Notebook class]])
        {
            Notebook *notebook = (Notebook *)object;
            cell = [self.layoutProvider getNewCell:tableView withNotebook:notebook];
        }
        if([object isKindOfClass:[Note class]])
        {
            Note *note = (Note *)object;
            cell = [self.layoutProvider getNewCell:tableView withNote:note];
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

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle;
    if(section == NOTEBOOKS_SECTION)
    {
        headerTitle = NOTEBOOK_SECTION_NAME;
    }
    if(section == REMINDERS_SECTION)
    {
        headerTitle = REMINDERS_SECTION_NAME;
    }
    return headerTitle;
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
    [self.delegate hideLeftPanel];
}

@end
