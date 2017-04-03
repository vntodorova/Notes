//
//  ViewController.h
//  Notes
//
//  Created by Nemetschek A-Team on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutProvider.h"
#import "NoteCreationController.h"
#import "Note.h"

@interface ViewController : UIViewController <NoteCreationControllerDelegate, UITableViewDataSource,UITableViewDelegate, TableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray<Note *> *notesArray;
@property NSMutableArray<Note *> *draftsArray;
@property LayoutProvider *layoutProvider;

@end

