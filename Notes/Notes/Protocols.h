//
//  Protocols.h
//  Notes
//
//  Created by VCS on 4/6/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#ifndef Protocols_h
#define Protocols_h

@class Notebook;
@class Note;
@class TableViewCell;
@class EditableNotebookCell;

@protocol NoteManagerDelegate

- (void)addNote:(Note *)newNote toNotebook:(Notebook *)notebook;
- (void)addNote:(Note *)newNote toNotebookWithName:(NSString *)notebookName;

- (void)removeNote:(Note *)note fromNotebook:(Notebook *)notebookName;
- (void)removeNote:(Note *)note fromNotebookWithName:(NSString *)notebookName;

- (NSArray<Note *> *)getNoteListForNotebook:(Notebook *)notebook;
- (NSArray<Note *> *)getNoteListForNotebookWithName:(NSString *)notebookName;

- (NSURL*) getBaseURLforNote:(Note*) note inNotebook:(Notebook*) notebook;
- (NSURL*) getBaseURLforNote:(Note*) note inNotebookWithName:(NSString*) notebookName;

- (NSString*) saveImage:(NSDictionary*) imageInfo withName:(NSString*)imageName forNote:(Note*) note inNotebook:(Notebook*) notebook;
- (NSString*) saveImage:(NSDictionary*) imageInfo withName:(NSString*)imageName forNote:(Note*) note inNotebookWithName:(NSString*) notebookName;

- (void)renameNotebook:(Notebook*) notebook newName:(NSString*) newName;
- (void)renameNotebookWithName:(NSString*) oldName newName:(NSString*) newName;

- (void) deleteTempFolder;
- (void) createTempFolder;

- (void)exchangeNoteAtIndex:(NSInteger)firstIndex withNoteAtIndex:(NSInteger)secondIndex fromNotebook:(NSString *)notebookName;

@end

@protocol NoteBookManagerDelegate
- (void)addNotebook:(Notebook *)newNotebook;

- (void)removeNotebook:(Notebook *)notebook;
- (void)removeNotebookWithName:(NSString *)notebookName;

- (NSArray<Notebook *> *)getNotebookList;
- (NSArray *) getNotebookNamesList;
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
- (void)onThemeChanged;
@end

@protocol EditableCellDelegate

- (void)deleteButtonClickedOnCell:(EditableNotebookCell *)cell;
- (void)onCellNameChanged:(EditableNotebookCell *)cell;

@end

#endif /* Protocols_h */
