//
//  LeftPanelViewController.m
//  Notes
//
//  Created by Nemetschek A-Team on 4/3/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "LeftPanelViewController.h"
#import "Defines.h"
#import "Notebook.h"
#import "Reminder.h"
#import "DateTimeManager.h"
#import "LayoutProvider.h"

@interface LeftPanelViewController()

@property DateTimeManager *dateTimeManager;
@property LayoutProvider *layoutProvider;

@end

@implementation LeftPanelViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.isHidden = YES;
        self.view.frame = CGRectMake(-1 * LEFT_PANEL_WIDTH, 0, LEFT_PANEL_WIDTH, self.view.frame.size.height);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dateTimeManager = [[DateTimeManager alloc] init];
    self.layoutProvider = [[LayoutProvider alloc] init];
    self.notebooks = [[NSMutableArray alloc] init];
    
    Notebook* notebook1 = [[Notebook alloc] init];
    notebook1.name = @"General";
    
    Notebook* notebook2 = [[Notebook alloc] init];
    notebook2.name = @"Work";
    
    Notebook* notebook3 = [[Notebook alloc] init];
    notebook3.name = @"Home";
    
    [self.notebooks addObject:notebook1];
    [self.notebooks addObject:notebook2];
    [self.notebooks addObject:notebook3];
    
    self.reminders = [[NSMutableArray alloc] init];
    
    Reminder *reminder1 = [[Reminder alloc] init];
    reminder1.name = @"Wash the car";
    reminder1.triggerDate = @"13:00:00, 06-04-2018";

    Reminder *reminder2 = [[Reminder alloc] init];
    reminder2.name = @"Random reminder name";
    reminder2.triggerDate = @"13:00:00, 15-05-2017";
    
    Reminder *reminder3 = [[Reminder alloc] init];
    reminder3.name = @"Add Settings button";
    reminder3.triggerDate = @"13:00:00, 15-06-2017";
    
    [self.reminders addObject:reminder1];
    [self.reminders addObject:reminder2];
    [self.reminders addObject:reminder3];
    [self.reminders sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Reminder *reminder1 = (Reminder *)obj1;
        Reminder *reminder2 = (Reminder *)obj2;
        return [self.dateTimeManager compareStringDate:reminder1.triggerDate andDate:reminder2.triggerDate];
    }];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark TableView delegates

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if(indexPath.section == NOTEBOOKS_SECTION)
    {
        Notebook *notebook = [self.notebooks objectAtIndex:indexPath.row];
        cell = [self.layoutProvider getNewCell:tableView withNotebook:notebook];
    }
    
    if(indexPath.section == REMINDERS_SECTION)
    {
        Reminder *reminder = [self.reminders objectAtIndex:indexPath.row];
        cell = [self.layoutProvider getNewCell:tableView withReminder:reminder];
    }

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if(section == NOTEBOOKS_SECTION)
    {
        numberOfRows = [self.notebooks count];
    }
    if(section == REMINDERS_SECTION)
    {
        numberOfRows = [self.reminders count];
    }
    return numberOfRows;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TABLEVIEW_SECTIONS_NUMBER;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle;
    if(section == NOTEBOOKS_SECTION)
    {
        headerTitle = @"Notebooks";
    }
    if(section == REMINDERS_SECTION)
    {
        headerTitle = @"Reminders";
    }
    return headerTitle;
}

@end
