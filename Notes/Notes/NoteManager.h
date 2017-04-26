//
//  NoteManager.h
//  Notes
//
//  Created by Nemetschek A-Team on 4/25/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.h"

@interface NoteManager : NSObject <NoteManagerDelegate, NotebookManagerDelegate>

- (NSString *)getNoteDirectoryPathForNote:(Note *)note inNotebookWithName:(NSString *)notebookName;

- (void)deleteTempFolder;
- (void)createTempFolder;

- (void)exchangeNoteAtIndex:(NSInteger)firstIndex withNoteAtIndex:(NSInteger)secondIndex fromNotebook:(NSString *)notebookName;

- (Notebook *)notebookContainingNote:(Note *)note;
- (NSArray<Note *> *)getNoteListForNotebook:(Notebook *)notebook;
- (NSArray<Note *> *)getNoteListForNotebookWithName:(NSString *)notebookName;
- (NSArray<Note *> *)getAllNotes;

- (NSURL*) getBaseURLforNote:(Note*) note inNotebook:(Notebook*) notebook;
- (NSURL*) getBaseURLforNote:(Note*) note inNotebookWithName:(NSString*) notebookName;
- (NSArray<Notebook *> *)getNotebookList;
- (NSArray *) getNotebookNamesList;

@end
