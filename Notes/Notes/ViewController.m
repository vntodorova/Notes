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

@interface ViewController()

@property (nonatomic, strong) LayoutProvider *layoutProvider;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.layoutProvider = [[LayoutProvider alloc] init];
    self.notesArray = [[NSMutableArray alloc] init];
    [self setupNavigationBar];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:TABLEVIEW_CELL_ID];
    
    //TEST CODE
    Note *note1 = [[Note alloc] init];
    note1.name = @"1st note";
    note1.dateCreated = @"12:34, 4.5.2016";
    [self.notesArray addObject:note1];
    
    Note *note2 = [[Note alloc] init];
    note2.name = @"2nd note";
    note2.dateCreated = @"12:35, 4.5.2016";
    [self.notesArray addObject:note2];
    
    Note *note3 = [[Note alloc] init];
    note3.name = @"3rd note";
    note3.dateCreated = @"12:35, 4.5.2016";
    [self.notesArray addObject:note3];
    
    Note *note4 = [[Note alloc] init];
    note4.name = @"4th note";
    note4.dateCreated = @"12:35, 4.5.2016";
    [self.notesArray addObject:note4];
    
    Note *note5 = [[Note alloc] init];
    note5.name = @"5th note";
    note5.dateCreated = @"12:35, 4.5.2016";
    [self.notesArray addObject:note5];
    
    [self.tableView reloadData];
    //TEST CODE
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    self.layoutProvider.bluredView.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, size.width, size.height);
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

- (void)showDrawer
{
    [self.view bringSubviewToFront:self.layoutProvider.bluredView];
    [self.view bringSubviewToFront:self.leftPanelViewController.view];
    self.leftPanelViewController.isHidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.layoutProvider.bluredView.alpha = 0.9;
        self.leftPanelViewController.view.frame = CGRectMake(0, 0, LEFT_PANEL_WIDTH, self.view.frame.size.height);
    }];
}

- (void)hideDrawer
{
    self.leftPanelViewController.isHidden = YES;
    [UIView animateWithDuration:0.5 animations:^{
        self.layoutProvider.bluredView.alpha = 0;
        self.leftPanelViewController.view.frame = CGRectMake(-1 * LEFT_PANEL_WIDTH, 0, LEFT_PANEL_WIDTH, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        [self.view sendSubviewToBack:self.layoutProvider.bluredView];
    }];
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
        [self.view addSubview:self.layoutProvider.bluredView];
        [self.view sendSubviewToBack:self.layoutProvider.bluredView];
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
    
    NoteCreationController *noteCreationController = [[NoteCreationController alloc] init];
    noteCreationController.note = note;
    noteCreationController.delegate = self;
    [self.navigationController pushViewController:noteCreationController animated:YES];
}

#pragma mark -
#pragma mark TableViewCell delegates

- (void)panGestureRecognisedOnCell:(TableViewCell *)cell
{
    NSIndexPath *pathForDeleting = [self.tableView indexPathForCell:cell];
    [self.notesArray removeObject:cell.cellNote];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:pathForDeleting] withRowAnimation:UITableViewRowAnimationRight];
}

- (void)exchangeObjectAtIndex:(NSInteger)firstIndex withObjectAtIndex:(NSInteger)secondIndex
{
     [self.notesArray exchangeObjectAtIndex:firstIndex withObjectAtIndex:secondIndex];
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
    TableViewCell *cell = [self.layoutProvider getNewCell:tableView withNote:note];
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

-(void)onDraftCreated:(Note *)draft
{
    [self.draftsArray addObject:draft];
}

-(void)onNoteCreated:(Note *)note
{
    [self.notesArray addObject:note];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark LeftPanelViewController delegates

- (void)hideLeftPanel
{
    [self hideDrawer];
}

@end
