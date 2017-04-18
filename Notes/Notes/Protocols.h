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

@protocol NoteManagerDelegate
- (void)addNote:(Note *)newNote toNotebook:(Notebook *)notebook;
- (void)addNote:(Note *)newNote toNotebookWithName:(NSString *)notebookName;

- (void)removeNote:(Note *)note fromNotebook:(Notebook *)notebookName;
- (void)removeNote:(Note *)note fromNotebookWithName:(NSString *)notebookName;

- (NSArray<Note *> *)getNoteListForNotebook:(Notebook *)notebook;
- (NSArray<Note *> *)getNoteListForNotebookWithName:(NSString *)notebookName;

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
- (void)onThemeChanged;
@end

#endif /* Protocols_h */
