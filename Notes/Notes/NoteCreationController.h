//
//  NoteCreationController.h
//  Notes
//
//  Created by VCS on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@protocol NoteCreationControllerDelegade

- (void)onNoteCreated:(Note*)note;
- (void)onDraftCreated:(Note*)draft;

@end

@interface NoteCreationController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *noteTags;

@property (weak, nonatomic) IBOutlet UITextField *noteName;

@property (weak, nonatomic) IBOutlet UITextView *noteBody;

@property (weak, nonatomic) id<NoteCreationControllerDelegade> delegade;

@property Note *note;

- (IBAction)onOptionsClick:(id)sender;

- (IBAction)onCreateClick:(id)sender;

@end
