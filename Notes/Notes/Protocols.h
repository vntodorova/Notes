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
- (void)removeNote:(Note *)newNote fromNotebook:(NSString *)notebookName;
- (void)exchangeNoteAtIndex:(NSInteger)firstIndex withNoteAtIndex:(NSInteger)secondIndex fromNotebook:(NSString *)notebookName;
- (NSArray<Note *> *)getNoteListForNotebook:(Notebook *)notebook;
- (NSArray<Note *> *)getNoteListForNotebookWithName:(NSString *)notebookName;
@end

@protocol NoteBookManagerDelegate
- (void)addNotebook:(Notebook *)newNotebook;
- (void)removeNotebook:(Notebook *)notebook;
- (NSArray<Notebook *> *)getNotebookList;
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
