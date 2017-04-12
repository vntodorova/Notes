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

@interface ViewController()

@property (nonatomic, strong) LayoutProvider *layoutProvider;
@property (nonatomic, strong) LocalNoteManager *noteManager;
@property (nonatomic, strong) ThemeManager *themeManager;
@property NSString *currentNotebook;
@property UIVisualEffectView *bluredView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    self.layoutProvider = [LayoutProvider sharedInstance];
    [self setupNavigationBar];
    self.noteManager = [[LocalNoteManager alloc] init];
    self.themeManager = [ThemeManager sharedInstance];
    [self.themeManager reload];
    [self loadTheme];
    self.currentNotebook = @"General";
    self.notesArray = [self.noteManager getNoteListForNotebookWithName:self.currentNotebook];
    [self.tableView registerNib:[UINib nibWithNibName:TABLEVIEW_CELL_ID bundle:nil] forCellReuseIdentifier:TABLEVIEW_CELL_ID];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNoteCreated) name:NOTE_CREATED_EVENT object:nil];
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
    [self.navigationController.navigationBar setTintColor:[self.themeManager.styles objectForKey:TEXT_COLOR]];
    UIBarButtonItem *leftNavigationBarButton = [self.layoutProvider setupLeftBarButton:self
                                                                          withSelector:@selector(drawerButtonPressed)];
    self.navigationController.topViewController.navigationItem.leftBarButtonItem = leftNavigationBarButton;
    leftNavigationBarButton.enabled = TRUE;
    
    UIBarButtonItem *rightNavigationBarButton = [self.layoutProvider setupRightBarButton:self
                                                                            withSelector:@selector(addButtonPressed)];
    self.navigationController.topViewController.navigationItem.rightBarButtonItem = rightNavigationBarButton;
    rightNavigationBarButton.enabled = TRUE;
    
    self.navigationController.topViewController.navigationItem.titleView = [self.themeManager.styles objectForKey:SEARCH_BAR];
}

- (void)loadTheme
{
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
    Note* note = [[Note alloc] init];
    [self showNoteCreationControllerWithNote:note];
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
    [self.noteManager removeNote:cell.cellNote fromNotebook:self.currentNotebook];
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
    TableViewCell *cell = [self.layoutProvider getNewTableViewCell:tableView withNote:note];
    cell.tableView = tableView;
    cell.delegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLEVIEW_CELL_HEIGHT;
}

#pragma mark -
#pragma mark NoteCreationController delegates

-(void)onNoteCreated
{
    self.notesArray = [self.noteManager getNoteListForNotebookWithName:self.currentNotebook];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark LeftPanelViewController delegates

- (void)hideLeftPanel
{
    self.settingsPanelViewController.isHidden = YES;
    self.leftPanelViewController.isHidden = YES;
    [UIView animateWithDuration:0.5 animations:^{
        self.bluredView.alpha = 0;
        self.leftPanelViewController.view.frame = CGRectMake(-1 * LEFT_PANEL_WIDTH, 0, LEFT_PANEL_WIDTH, self.view.frame.size.height);
        self.settingsPanelViewController.view.frame = CGRectMake(-1 * LEFT_PANEL_WIDTH, 0, LEFT_PANEL_WIDTH, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        [self.view sendSubviewToBack:self.bluredView];
    }];
}

- (void)showLeftPanel
{
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
    [self.themeManager reload];
    [self loadTheme];
    [self.leftPanelViewController loadTheme];
}

#pragma mark -
#pragma mark Gesture recogniser delegates

- (void)tapGestureRecognised:(UITapGestureRecognizer *)tap
{
    [self hideLeftPanel];
}

@end
