//
//  LocalNoteManager.h
//  Notes
//
//  Created by VCS on 4/6/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.h"

@interface LocalNoteManager : NSObject <NoteManagerDelegate, NoteBookManagerDelegate>

- (void)addNotebook:(Notebook *) newNotebook;
- (void)removeNotebook:(Notebook *)notebook;
- (void)addNote:(Note *)newNote toNotebook:(Notebook *)notebook;
- (void)removeNote:(Note *)note fromNotebook:(Notebook *)notebook;
- (NSArray *)getNotebookList;
- (NSArray<Note *> *)getNoteListForNotebook:(Notebook *)notebook;
- (NSArray<Note *> *)getNoteListForNotebookWithName:(NSString *)notebookName;


@end
