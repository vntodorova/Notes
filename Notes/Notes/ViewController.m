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
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.layoutProvider = [[LayoutProvider alloc] init];
    self.notesArray = [[NSMutableArray alloc] init];
    [self setupNavigationBar];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:TABLEVIEW_CELL_ID];
    
    Note *note1 = [[Note alloc] init];
    note1.name = @"First note";
    note1.dateCreated = @"12:34, 4.5.2016";
    [self.notesArray addObject:note1];
    
    Note *note2 = [[Note alloc] init];
    note2.name = @"Second note";
    note2.dateCreated = @"12:35, 4.5.2016";
    [self.notesArray addObject:note2];
    
    [self.tableView reloadData];
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
    noteCreationController.delegade = self;
    [self.navigationController pushViewController:noteCreationController animated:YES];
}

#pragma mark TableView delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.notesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Note *note = [self.notesArray objectAtIndex:indexPath.row];
    return [self.layoutProvider getNewCell:tableView withNote:note];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma DELEGADE METHODS

-(void)onDraftCreated:(Note *)draft
{
    NSLog(@"Draft created %@",draft);
}

-(void)onNoteCreated:(Note *)note
{
    NSLog(@"Note created %@",note);
}

@end
