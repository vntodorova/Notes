//
//  ViewController.m
//  Notes
//
//  Created by Nemetschek A-Team on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "ViewController.h"
#import "Defines.h"
#import "NoteCreationController.h"
#import "TableViewCell.h"
#import "LeftPanelViewController.h"
#import "LayoutProvider.h"
#import "SettingsPanelViewController.h"
#import "LocalNoteManager.h"
#import "ThemeManager.h"
#import "Note.h"

@interface ViewController()

@property (nonatomic, strong) LayoutProvider *layoutProvider;
@property (nonatomic, strong) LocalNoteManager *noteManager;
@property (nonatomic, strong) ThemeManager *themeManager;
@property (nonatomic, strong) LeftPanelViewController *leftPanelViewController;
@property (nonatomic, strong) SettingsPanelViewController *settingsPanelViewController;
@property NSString *currentNotebook;
@property NSArray<Note *> *notesArray;
@property UIVisualEffectView *bluredView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    self.layoutProvider = [LayoutProvider sharedInstance];
    self.noteManager = [[LocalNoteManager alloc] init];
    self.themeManager = [ThemeManager sharedInstance];
    self.currentNotebook = GENERAL_NOTEBOOK_NAME;
    
    [self setupNavigationBar];
    [self loadTheme];
    [self reloadTableViewData];
    [self.tableView registerNib:[UINib nibWithNibName:TABLEVIEW_CELL_ID bundle:nil] forCellReuseIdentifier:TABLEVIEW_CELL_ID];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNoteCreated) name:NOTE_CREATED_EVENT object:nil];
}

- (void)reloadTableViewData
{
    self.notesArray = [self.noteManager getNoteListForNotebookWithName:self.currentNotebook];
    [self.tableView reloadData];
}

-   (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    self.bluredView.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, size.width, size.height);
}

- (void)setupBlurView
{
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.bluredView = [[UIVisualEffectView alloc] initWithEffect:effect];
    self.bluredView.frame = [UIScreen mainScreen].bounds;
    self.bluredView.alpha = 0;
    self.bluredView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    UITapGestureRecognizer *tapRecogniser = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(tapGestureRecognised:)];
    [self.bluredView addGestureRecognizer:tapRecogniser];
    tapRecogniser.delegate = self;
}

- (void)setupNavigationBar
{
    [self.navigationController.navigationBar setTintColor:[self.themeManager.styles objectForKey:TINT]];
    UIBarButtonItem *leftNavigationBarButton = [self.layoutProvider setupLeftBarButton:self
                                                                          withSelector:@selector(drawerButtonPressed)];
    self.navigationController.topViewController.navigationItem.leftBarButtonItem = leftNavigationBarButton;
    leftNavigationBarButton.enabled = TRUE;
    
    UIBarButtonItem *rightNavigationBarButton = [self.layoutProvider setupRightBarButton:self
                                                                            withSelector:@selector(addButtonPressed)];
    self.navigationController.topViewController.navigationItem.rightBarButtonItem = rightNavigationBarButton;
    rightNavigationBarButton.enabled = TRUE;
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    [searchBar setBarStyle:[[self.themeManager.styles objectForKey:SEARCH_BAR] integerValue]];
    self.navigationController.topViewController.navigationItem.titleView = searchBar;
}

- (void)loadTheme
{
    [self.themeManager reload];
    self.tableView.backgroundColor = [self.themeManager.styles objectForKey:TABLEVIEW_BACKGROUND_COLOR];
    [self.navigationController.navigationBar setBarTintColor:[self.themeManager.styles objectForKey:NAVIGATION_BAR_COLOR]];
    [self.tableView reloadData];
    [self setupNavigationBar];
}

- (void)setupLeftPanel
{
    self.leftPanelViewController = [[LeftPanelViewController alloc] initWithNibName:LEFT_PANEL_NIBNAME bundle:nil manager:self.noteManager];
    self.leftPanelViewController.delegate = self;
    [self.view addSubview:self.leftPanelViewController.view];
    [self setupBlurView];
    [self.view addSubview:self.bluredView];
    [self.view sendSubviewToBack:self.bluredView];
}

- (void)setupSettingsPanel
{	
    self.settingsPanelViewController = [[SettingsPanelViewController alloc] initWithNibName:SETTINGS_PANEL_NIBNAME bundle:nil manager:self.noteManager];
    self.settingsPanelViewController.delegate = self;
    [self.view addSubview:self.settingsPanelViewController.view];
}

#pragma mark -
#pragma mark Navigation bar buttons

- (void)drawerButtonPressed
{
    if(self.leftPanelViewController == nil)
    {
        [self setupLeftPanel];
    }
    
    if(self.leftPanelViewController.isHidden)
    {
        [self showLeftPanel];
    }
    else
    {
        [self hideLeftPanel];
    }
}

- (void)addButtonPressed
{
    [self showNoteCreationControllerWithNote:[[Note alloc] init]];
}

-(void) showNoteCreationControllerWithNote:(Note *) note
{
    NoteCreationController *noteCreationController = [[NoteCreationController alloc] initWithManager:self.noteManager];
    noteCreationController.note = note;
    noteCreationController.currentNotebook = self.currentNotebook;
    [self.navigationController pushViewController:noteCreationController animated:YES];
}

#pragma mark -
#pragma mark TableViewCell delegates

- (void)panGestureRecognisedOnCell:(TableViewCell *)cell
{
    NSIndexPath *pathForDeleting = [self.tableView indexPathForCell:cell];
    [self.noteManager removeNote:cell.cellNote fromNotebookWithName:self.currentNotebook];
    self.notesArray = [self.noteManager getNoteListForNotebookWithName:self.currentNotebook];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:pathForDeleting] withRowAnimation:UITableViewRowAnimationRight];
}

- (void)tapGestureRecognisedOnCell:(TableViewCell *)cell
{
    [self showNoteCreationControllerWithNote:cell.cellNote];
}

- (void)exchangeObjectAtIndex:(NSInteger)firstIndex withObjectAtIndex:(NSInteger)secondIndex
{
    [self.noteManager exchangeNoteAtIndex:firstIndex withNoteAtIndex:secondIndex fromNotebook:self.currentNotebook];
}

#pragma mark -
#pragma mark TableView delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.notesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Note *note = [self.notesArray objectAtIndex:indexPath.row];
    return [self.layoutProvider getNewTableViewCell:tableView withNote:note andDelegate:self];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLEVIEW_CELL_HEIGHT;
}

#pragma mark -
#pragma mark NoteCreationController delegates

-(void)onNoteCreated
{
    [self reloadTableViewData];
}

#pragma mark -
#pragma mark LeftPanelViewController delegates

- (void)hideLeftPanel
{
    [self.leftPanelViewController exitEditingMode];
    self.settingsPanelViewController.isHidden = YES;
    self.leftPanelViewController.isHidden = YES;
    [UIView animateWithDuration:0.5 animations:^{
        self.bluredView.alpha = 0;
        CGRect hiddenFrame = CGRectMake(-1 * LEFT_PANEL_WIDTH, 0, LEFT_PANEL_WIDTH, self.view.frame.size.height);
        self.leftPanelViewController.view.frame = hiddenFrame;
        self.settingsPanelViewController.view.frame = hiddenFrame;
    } completion:^(BOOL finished) {
        [self.view sendSubviewToBack:self.bluredView];
    }];
}

- (void)showLeftPanel
{
    [self.leftPanelViewController reloadTableViewData];
    [self.view bringSubviewToFront:self.bluredView];
    [self.view bringSubviewToFront:self.leftPanelViewController.view];
    self.leftPanelViewController.isHidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.bluredView.alpha = 0.9;
        self.leftPanelViewController.view.frame = CGRectMake(0, 0, LEFT_PANEL_WIDTH, self.view.frame.size.height);
    }];
}

- (void)showSettings
{
    if(self.settingsPanelViewController == nil)
    {
         [self setupSettingsPanel];
    }
    [self.view bringSubviewToFront:self.settingsPanelViewController.view];
    self.settingsPanelViewController.isHidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.settingsPanelViewController.view.frame = CGRectMake(0, 0, LEFT_PANEL_WIDTH, self.view.frame.size.height);
    }];
}

- (void)onThemeChanged
{
    [self loadTheme];
    [self.leftPanelViewController loadTheme];
}

- (void)changeCurrentNotebook:(NSString *)newNotebookName
{
    self.currentNotebook = newNotebookName;
    self.notesArray = [self.noteManager getNoteListForNotebookWithName:self.currentNotebook];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Gesture recogniser delegates

- (void)tapGestureRecognised:(UITapGestureRecognizer *)tap
{
    [self hideLeftPanel];
}

@end
