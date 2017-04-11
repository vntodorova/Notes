//
//  ViewController.h
//  Notes
//
//  Created by Nemetschek A-Team on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteCreationController.h"
#import "PublicProtocols.h"

@class LeftPanelViewController;
@class Note;
@class LayoutProvider;
@class SettingsPanelViewController;

@interface ViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, TableViewCellDelegate, LeftPanelDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) LeftPanelViewController *leftPanelViewController;
@property (nonatomic, strong) SettingsPanelViewController *settingsPanelViewController;

@property NSArray<Note *> *notesArray;


@end

