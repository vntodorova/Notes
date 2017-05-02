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
#import "NoteManager.h"
#import "LocalNoteManager.h"
#import "DropboxNoteManager.h"
#import "ThemeManager.h"
#import "Note.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@interface ViewController()

@property (nonatomic, strong) LayoutProvider *layoutProvider;
@property (nonatomic, strong) NoteManager *noteManager;
@property (nonatomic, strong) LocalNoteManager *localNoteManager;
@property (nonatomic, strong) DropboxNoteManager *dropboxManager;
@property (nonatomic, strong) ThemeManager *themeManager;
@property (nonatomic, strong) LeftPanelViewController *leftPanelViewController;
@property (nonatomic, strong) SettingsPanelViewController *settingsPanelViewController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property NSString *currentNotebook;
@property NSArray *notesArray;
@property UIVisualEffectView *bluredView;
@property NSMutableArray *filteredNotes;
@property NSArray *allNotes;
@property BOOL isSearching;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                   controller:self
                                      openURL:^(NSURL *url) {
                                          [[UIApplication sharedApplication] openURL:url];
                                      }];
    
    self.layoutProvider = [LayoutProvider sharedInstance];
    self.localNoteManager = [[LocalNoteManager alloc] init];
    self.noteManager = [[NoteManager alloc] init];
    self.themeManager = [ThemeManager sharedInstance];
    self.filteredNotes = [[NSMutableArray alloc] init];
    self.allNotes = [self.noteManager getAllNotes];
    self.currentNotebook = GENERAL_NOTEBOOK_NAME;
    [self createGeneralNotebook];
    [self setupNavigationBar];
    [self loadTheme];
    [self reloadTableViewData];
    [self.tableView registerNib:[UINib nibWithNibName:TABLEVIEW_CELL_ID bundle:nil] forCellReuseIdentifier:TABLEVIEW_CELL_ID];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNoteCreated) name:NOTE_LIST_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNoteCreated) name:NOTE_CREATED_EVENT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onThemeChanged) name:THEME_CHANGED_EVENT object:nil];
}

- (void)createGeneralNotebook
{
    [self.noteManager addNotebookWithName:GENERAL_NOTEBOOK_NAME];
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
                                                                          action:@selector(drawerButtonPressed)];
    self.navigationController.topViewController.navigationItem.leftBarButtonItem = leftNavigationBarButton;
    leftNavigationBarButton.enabled = TRUE;
    
    UIBarButtonItem *rightNavigationBarButton = [self.layoutProvider setupRightBarButton:self
                                                                            action:@selector(addButtonPressed)];
    self.navigationController.topViewController.navigationItem.rightBarButtonItem = rightNavigationBarButton;
    rightNavigationBarButton.enabled = TRUE;
    
    self.searchBar = [[UISearchBar alloc] init];
    [self.searchBar setBarStyle:[[self.themeManager.styles objectForKey:SEARCH_BAR] integerValue]];
    self.searchBar.delegate = self;
    self.navigationController.topViewController.navigationItem.titleView = self.searchBar;
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
    self.leftPanelViewController.presentingViewControllerDelegate = self;
    [self.view addSubview:self.leftPanelViewController.view];
    [self setupBlurView];
    [self.view addSubview:self.bluredView];
    [self.view sendSubviewToBack:self.bluredView];
}

- (void)setupSettingsPanel
{
    self.settingsPanelViewController = [[SettingsPanelViewController alloc] initWithNibName:SETTINGS_PANEL_NIBNAME bundle:nil];
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
    if(self.isSearching)
    {
        return [self.filteredNotes count];
    }
    else
    {
        return [self.notesArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isSearching)
    {
        Note *note = [self.filteredNotes objectAtIndex:indexPath.row];
        return [self.layoutProvider searchResultCellWithNote:note notebook:[self.noteManager notebookContainingNote:note]];
    }
    else
    {
        return [self.layoutProvider newTableViewCell:tableView note:[self.notesArray objectAtIndex:indexPath.row] delegate:self];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLEVIEW_CELL_HEIGHT;
}

#pragma mark -
#pragma mark Notification handlers

- (void)onNoteCreated
{
    self.allNotes = [self.noteManager getAllNotes];
    [self reloadTableViewData];
}

- (void)onThemeChanged
{
    [self loadTheme];
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

- (void)changeCurrentNotebook:(NSString *)newNotebookName
{
    self.currentNotebook = newNotebookName;
    self.notesArray = [self.noteManager getNoteListForNotebookWithName:self.currentNotebook];
    [self.tableView reloadData];
}

-(void)authDropbox
{
    [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                   controller:self
                                      openURL:^(NSURL *url) {
                                          [[UIApplication sharedApplication] openURL:url];
                                      }];
}

#pragma mark -
#pragma mark Gesture recogniser delegates

- (void)tapGestureRecognised:(UITapGestureRecognizer *)tap
{
    [self hideLeftPanel];
}

#pragma mark -
#pragma mark SearchBar delegates

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.isSearching = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.filteredNotes removeAllObjects];
    
    if([searchText length] != 0)
    {
        self.isSearching = YES;
        [self filterNotes];
    }
    else
    {
        self.isSearching = NO;
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)filterNotes
{
    NSString *searchString = self.searchBar.text;
    for (Note *currentNote in self.allNotes)
    {
        NSString *currentNoteName = currentNote.name;
        
        if ([currentNoteName rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [self.filteredNotes addObject:currentNote];
        }
    }
}

@end
