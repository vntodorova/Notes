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
#import "LocalNoteManager.h"

@interface ViewController()

@property (nonatomic, strong) LayoutProvider *layoutProvider;
@property (nonatomic, strong) LocalNoteManager *manager;
@property UIVisualEffectView *bluredView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.layoutProvider = [LayoutProvider sharedInstance];
    self.manager = [[LocalNoteManager alloc] init];
    self.notesArray = [[NSMutableArray alloc] init];
    
    [self setupNavigationBar];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:TABLEVIEW_CELL_ID];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNoteCreated) name:@NOTE_CREATED_EVENT object:nil];
    self.notesArray = [self.manager getNoteListForNotebookWithName:@"General"];
    //TEST CODE
    
    Note *note1 = [[Note alloc] init];
    note1.name = @"1st note";
    note1.dateCreated = @"12:34, 4.5.2016";
    
    NSArray *notebookList = [self.manager getNotebookList];
    
    [self.manager addNote:note1 toNotebook:[notebookList objectAtIndex:0]];
    
    [self.tableView reloadData];
    //TEST CODE
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
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
    
    UITapGestureRecognizer *tapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognised:)];
    [self.bluredView addGestureRecognizer:tapRecogniser];
    tapRecogniser.delegate = self;
}

- (void)setupNavigationBar
{
    UIBarButtonItem *leftNavigationBarButton = [self.layoutProvider setupLeftBarButton:self withSelector:@selector(drawerButtonPressed)];
    self.navigationController.topViewController.navigationItem.leftBarButtonItem = leftNavigationBarButton;
    leftNavigationBarButton.enabled = TRUE;
    
    UIBarButtonItem *rightNavigationBarButton = [self.layoutProvider setupRightBarButton:self withSelector:@selector(addButtonPressed)];
    self.navigationController.topViewController.navigationItem.rightBarButtonItem = rightNavigationBarButton;
    rightNavigationBarButton.enabled = TRUE;
    
    self.navigationController.topViewController.navigationItem.titleView = [[UISearchBar alloc] init];
}

#pragma mark -
#pragma mark Navigation bar buttons

- (void)drawerButtonPressed
{
    if(!self.leftPanelViewController)
    {
        self.leftPanelViewController = [[LeftPanelViewController alloc] initWithNibName:@"LeftPanelViewController" bundle:nil];
        self.leftPanelViewController.delegate = self;
        [self.view addSubview:self.leftPanelViewController.view];
        [self setupBlurView];
        [self.view addSubview:self.bluredView];
        [self.view sendSubviewToBack:self.bluredView];
    }
    
    if(self.leftPanelViewController.isHidden)
    {
        [self showDrawer];
    }
    else
    {
        [self hideDrawer];
    }
}

- (void)addButtonPressed
{
    Note* note = [[Note alloc] init];
    note.body = @"This text is here to be eddited and tested";
    
    NoteCreationController *noteCreationController = [[NoteCreationController alloc] initWithManager:self.manager];
    noteCreationController.note = note;
    [self.navigationController pushViewController:noteCreationController animated:YES];
}

#pragma mark -
#pragma mark TableViewCell delegates

- (void)panGestureRecognisedOnCell:(TableViewCell *)cell
{
    NSIndexPath *pathForDeleting = [self.tableView indexPathForCell:cell];
   // [self.notesArray removeObject:cell.cellNote];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:pathForDeleting] withRowAnimation:UITableViewRowAnimationRight];
}

- (void)exchangeObjectAtIndex:(NSInteger)firstIndex withObjectAtIndex:(NSInteger)secondIndex
{
 //    [self.notesArray exchangeObjectAtIndex:firstIndex withObjectAtIndex:secondIndex];
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
    self.notesArray = [self.manager getNoteListForNotebookWithName:@"General"];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark LeftPanelViewController delegates

- (void)hideLeftPanel
{
    [self hideDrawer];
}

- (void)showDrawer
{
    [self.view bringSubviewToFront:self.bluredView];
    [self.view bringSubviewToFront:self.leftPanelViewController.view];
    self.leftPanelViewController.isHidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.bluredView.alpha = 0.9;
        self.leftPanelViewController.view.frame = CGRectMake(0, 0, LEFT_PANEL_WIDTH, self.view.frame.size.height);
    }];
}

- (void)hideDrawer
{
    self.leftPanelViewController.isHidden = YES;
    [UIView animateWithDuration:0.5 animations:^{
        self.bluredView.alpha = 0;
        self.leftPanelViewController.view.frame = CGRectMake(-1 * LEFT_PANEL_WIDTH, 0, LEFT_PANEL_WIDTH, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        [self.view sendSubviewToBack:self.bluredView];
    }];
}

#pragma mark -
#pragma mark Gesture recogniser delegates

- (void)tapGestureRecognised:(UITapGestureRecognizer *)tap
{
    [self hideDrawer];
}

@end
