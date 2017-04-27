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

- (void)synchronize;

- (NSString *)noteDirectoryPathForNote:(Note *)note inNotebookWithName:(NSString *)notebookName;

- (void)deleteTempFolder;
- (void)createTempFolder;

- (void)exchangeNoteAtIndex:(NSInteger)firstIndex withNoteAtIndex:(NSInteger)secondIndex fromNotebook:(NSString *)notebookName;

- (Notebook *)notebookContainingNote:(Note *)note;
- (NSArray *)allNotes;

- (NSURL *)baseURLforNote:(Note *)note inNotebook:(Notebook *)notebook;
- (NSURL *)baseURLforNote:(Note *)note inNotebookWithName:(NSString *)notebookName;
- (NSArray *)notebookNamesList;

- (NSString *)saveImage:(NSDictionary *)imageInfo withName:(NSString *)imageName forNote:(Note *)note inNotebook:(Notebook *)notebook;
- (NSString *)saveImage:(NSDictionary *)imageInfo withName:(NSString *)imageName forNote:(Note *)note inNotebookWithName:(NSString *)notebookName;
- (NSString *)saveUIImage:(UIImage *)image withName:(NSString *)imageName forNote:(Note *)note inNotebookWithName:(NSString *)notebookName;

@end
