//
//  LeftPanelViewController.h
//  Notes
//
//  Created by Nemetschek A-Team on 4/3/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicProtocols.h"

@class Notebook;
@class Reminder;

@interface LeftPanelViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *googleButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) id <LeftPanelDelegate> delegate;

@property NSMutableDictionary *tableViewDataSource;

@property NSMutableDictionary *notebooksClicked;

@property BOOL isHidden;

@end