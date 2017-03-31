//
//  ViewController.m
//  Notes
//
//  Created by Nemetschek A-Team on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "LauncherViewController.h"
#import "Defines.h"
#import "NoteCreationController.h"
#import "TableViewCell.h"
@interface LauncherViewController ()

@end

@implementation LauncherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.layoutProvider = [[LayoutProvider alloc] init];
    self.notesArray = [[NSMutableArray alloc] init];
    [self setupNavigationBar];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:TABLEVIEW_CELL_ID];
    
    //TEST CODE
    Note *note1 = [[Note alloc] init];
    note1.name = @"First note";
    note1.dateCreated = @"12:34, 4.5.2016";
    [self.notesArray addObject:note1];
    
    Note *note2 = [[Note alloc] init];
    note2.name = @"Second note";
    note2.dateCreated = @"12:35, 4.5.2016";
    [self.notesArray addObject:note2];
    
    [self.tableView reloadData];
    //TEST CODE
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

- (void)drawerButtonPressed
{
    
}

- (void)addButtonPressed
{
    NoteCreationController *noteCreationController = [[NoteCreationController alloc]init];
    noteCreationController.note =[[Note alloc] init];
    noteCreationController.delegate = self;
    [self.navigationController pushViewController:noteCreationController animated:YES];
}

- (void)swipedCell:(UIPanGestureRecognizer *)drag onCell:(TableViewCell *)cell
{
    [UIView animateWithDuration:1 animations:^
     {
         CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
         cell.frame = CGRectMake(cell.frame.origin.x+screenWidth,cell.frame.origin.y, cell.frame.size.width , cell.frame.size.height);
     }];
    
    [UIView animateWithDuration:1 animations:^{
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        cell.frame = CGRectMake(cell.frame.origin.x+screenWidth,cell.frame.origin.y, cell.frame.size.width , cell.frame.size.height);
    } completion:^(BOOL finished) {
        [self.notesArray removeObject:cell.cellNote];
        [self.tableView reloadData];
    }];
}

#pragma mark TableView delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.notesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Note *note = [self.notesArray objectAtIndex:indexPath.row];
    TableViewCell *cell = [self.layoutProvider getNewCell:tableView withNote:note];
    cell.delegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLEVIEW_CELL_HEIGHT;
}

#pragma NoteCreationController delegates

-(void)onDraftCreated:(Note *)draft
{
    [self.draftsArray addObject:draft];
}

-(void)onNoteCreated:(Note *)note
{
    [self.notesArray addObject:note];
    [self.tableView reloadData];
}

@end
