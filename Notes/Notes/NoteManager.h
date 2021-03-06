//
//  NoteManager.h
//  Notes
//
//  Created by Nemetschek A-Team on 4/25/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.h"

@interface NoteManager : NSObject <NoteManagerDelegate, NotebookManagerDelegate, ResponseHandler>

- (NSString *)getNoteDirectoryPathForNote:(Note *)note inNotebookWithName:(NSString *)notebookName;

- (void)deleteTempFolder;
- (void)createTempFolder;

- (void)exchangeNoteAtIndex:(NSInteger)firstIndex withNoteAtIndex:(NSInteger)secondIndex fromNotebook:(NSString *)notebookName;

- (Notebook *)notebookContainingNote:(Note *)note;

- (NSURL *)getBaseURLforNote:(Note *)note inNotebook:(Notebook *)notebook;
- (NSURL *)getBaseURLforNote:(Note *)note inNotebookWithName:(NSString *)notebookName;
- (NSArray *)getNotebookNamesList;

- (NSString *)saveImage:(NSDictionary *)imageInfo withName:(NSString *)imageName forNote:(Note *)note inNotebook:(Notebook *)notebook;
- (NSString *)saveImage:(NSDictionary *)imageInfo withName:(NSString *)imageName forNote:(Note *)note inNotebookWithName:(NSString *)notebookName;
- (NSString *)saveUIImage:(UIImage *)image withName:(NSString *)imageName forNote:(Note *)note inNotebookWithName:(NSString *)notebookName;

- (NSArray *)getNoteListForNotebook:(Notebook *)notebook;
- (NSArray *)getNoteListForNotebookWithName:(NSString *)notebookName;

- (NSArray *)getNotebookList;

@end
