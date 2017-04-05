//
//  LeftPanelViewController.h
//  Notes
//
//  Created by Nemetschek A-Team on 4/3/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Notebook;
@class Reminder;

@interface LeftPanelViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray<Notebook *> *notebooks;
@property NSMutableArray<Reminder *> *reminders;
@property BOOL isHidden;

@end
