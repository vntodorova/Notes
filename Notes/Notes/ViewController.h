//
//  ViewController.h
//  Notes
//
//  Created by Nemetschek A-Team on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@class LeftPanelViewController;
@class Note;
@class LayoutProvider;
@class SettingsPanelViewController;
@class NoteCreationController;

@interface ViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, TableViewCellDelegate, LeftPanelDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

