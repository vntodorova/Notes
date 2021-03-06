//
//  Protocols.h
//  Notes
//
//  Created by VCS on 4/6/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#ifndef Protocols_h
#define Protocols_h

#import <UIKit/UIKit.h>

@class Notebook;
@class Note;
@class TableViewCell;
@class EditableNotebookCell;

@protocol NoteManagerDelegate

- (void)addNote:(Note *)newNote toNotebook:(Notebook *)notebook;
- (void)addNote:(Note *)newNote toNotebookWithName:(NSString *)notebookName;

- (void)removeNote:(Note *)note fromNotebook:(Notebook *)notebookName;
- (void)removeNote:(Note *)note fromNotebookWithName:(NSString *)notebookName;

- (void)renameNote:(Note *)note fromNotebook:(Notebook *)notebook oldName:(NSString *)oldName;
- (void)renameNote:(Note *)note fromNotebookWithName:(NSString *)notebookName oldName:(NSString *)oldName;

- (void)copyNote:(Note *)note fromNotebook:(Notebook *)source toNotebook:(Notebook *)destination;
- (void)copyNote:(Note *)note fromNotebookWithName:(NSString *)source toNotebookWithName:(NSString *)destination;

- (void)requestNoteListForNotebook:(Notebook *)notebook;
- (void)requestNoteListForNotebookWithName:(NSString *)notebookName;
@end

@protocol NotebookManagerDelegate

- (void)addNotebook:(Notebook *)newNotebook;
- (void)addNotebookWithName:(NSString *) notebookName;

- (void)removeNotebook:(Notebook *)notebook;
- (void)removeNotebookWithName:(NSString *)notebookName;

- (void)renameNotebook:(Notebook *)notebook newName:(NSString *)newName;
- (void)renameNotebookWithName:(NSString *)oldName newName:(NSString *)newName;

- (void)requestNotebookList;

@end

@protocol ResponseHandler

- (void)handleResponseWithNotebookList:(NSArray *)notebookList fromManager:(id)manager;
- (void)handleResponseWithNoteList:(NSArray *)noteList fromNotebook:(Notebook *)notebook fromManager:(id)manager;
- (void)handleResponseWithNoteList:(NSArray *)noteList fromNotebookWithName:(NSString *)notebookName fromManager:(id)manager;

@end

@protocol TableViewCellDelegate

- (void)panGestureRecognisedOnCell:(TableViewCell *)cell;
- (void)tapGestureRecognisedOnCell:(TableViewCell *)cell;
- (void)exchangeObjectAtIndex:(NSInteger)firstIndex withObjectAtIndex:(NSInteger)secondIndex;

@end

@protocol LeftPanelDelegate

- (void)hideLeftPanel;
- (void)showSettings;
- (void)changeCurrentNotebook:(NSString *)newNotebookName;

//TODO: testing
-(void)authDropbox;

@end

@protocol EditableCellDelegate

- (void)deleteButtonClickedOnCell:(EditableNotebookCell *)cell;
- (void)onCellNameChanged:(EditableNotebookCell *)cell;

@end

@protocol DrawingDelegate

- (void)drawingSavedAsImage:(UIImage *)image;

@end

@protocol DatePickerDelegate

-(void) reminderDateSelected:(NSDate* )date;

@end

#endif /* Protocols_h */
