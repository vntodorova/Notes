//
//  Protocols.h
//  Notes
//
//  Created by VCS on 4/6/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#ifndef Protocols_h
#define Protocols_h

#import "Notebook.h"
#import "Note.h"

@protocol NoteManagerDelegate

-(void) addNote:(Note*) newNote toNotebook:(Notebook*) notebook;

-(void) removeNote:(Note*) newNote fromNotebook:(Notebook*) notebook;

@end

@protocol NoteBookManagerDelegate

-(void) addNotebook:(Notebook*) newNotebook;

-(void) removeNotebook:(Notebook*) notebook;

-(NSArray<Notebook*>*) getNotebookList;

-(NSArray<Note*>*) getNoteListForNotebook:(Notebook*) notebook;

-(NSArray<Note*>*) getNoteListForNotebookWithName:(NSString*) notebookName;
@end

#endif /* Protocols_h */
