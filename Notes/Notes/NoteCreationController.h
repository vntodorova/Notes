//
//  NoteCreationController.h
//  Notes
//
//  Created by VCS on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface NoteCreationController : UIViewController
- (IBAction)onOptionsClick:(id)sender;
- (IBAction)onCreateClick:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *noteTags;
@property (weak, nonatomic) IBOutlet UITextField *noteName;
@property (weak, nonatomic) IBOutlet UITextView *noteBody;
@property Note *note;
@end
