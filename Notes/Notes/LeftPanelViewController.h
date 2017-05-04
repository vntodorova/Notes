//
//  LeftPanelViewController.h
//  Notes
//
//  Created by Nemetschek A-Team on 4/3/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@class Notebook;
@class Reminder;
@class NoteManager;

@interface LeftPanelViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, UIGestureRecognizerDelegate, EditableCellDelegate>

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil manager:(NoteManager *)noteManager;
- (IBAction)settingsButtonClicked:(UIButton *)sender;
- (void)loadTheme;
- (void)reloadTableViewData;
- (void)exitEditingMode;

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *googleButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UIViewController<LeftPanelDelegate>* presentingViewControllerDelegate;
@property NSMutableDictionary *tableViewDataSource;
@property BOOL isHidden;

@end
