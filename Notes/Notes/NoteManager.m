//
//  NoteManager.m
//  Notes
//
//  Created by Nemetschek A-Team on 4/25/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "NoteManager.h"
#import "LocalNoteManager.h"
#import "DropboxNoteManager.h"
#import "Reachability.h"
#import "Note.h"
#import "Defines.h"
#import "Note.h"
#import "Notebook.h"
#import "TagsParser.h"
#import "DateTimeManager.h"

@interface NoteManager()
@property (nonatomic, strong) LocalNoteManager *localManager;
@property (nonatomic, strong) DropboxNoteManager *dropboxManager;

@property TagsParser *tagParser;

@property NSMutableDictionary *notebookDictionary;
@property NSMutableArray *notebookList;

@property BOOL localDataLoaded;
@property BOOL dropboxDataLoaded;

@property NSMutableDictionary *localNotebookDictionary;
@property NSMutableDictionary *dropboxNotebookDictionary;

@end

@implementation NoteManager

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.localManager = [[LocalNoteManager alloc] initWithResponseHandler:self];
        self.dropboxManager = [[DropboxNoteManager alloc] initWithManager:self handler:self];
        self.localNotebookDictionary = [[NSMutableDictionary alloc] init];
        self.dropboxNotebookDictionary = [[NSMutableDictionary alloc] init];
        self.notebookDictionary = [[NSMutableDictionary alloc] init];
        self.notebookList = [[NSMutableArray alloc] init];
        self.tagParser = [[TagsParser alloc] init];
    }
    return self;
}

- (void)removeNotebookFromAllLists:(NSString *)notebookName
{
    [self.notebookDictionary removeObjectForKey:notebookName];
    [self.notebookList removeObject:[self getNotebookWithName:notebookName]];
}

- (NSArray *)getNotebookNamesList
{
    return self.notebookDictionary.allKeys;
}

- (BOOL)noteExists:(Note *)newNote inNotebookWithName:(NSString *)notebookName
{
    NSArray *noteList = [self getNoteListForNotebookWithName:notebookName];
    for(Note *note in noteList)
    {
        if([note.name isEqualToString:newNote.name])
        {
            return YES;
        }
    }
    return NO;
}

- (Notebook *)getNotebookWithName:(NSString *)notebookName
{
    for (Notebook *currentNotebook in self.notebookList)
    {
        if([currentNotebook.name isEqualToString:notebookName])
        {
            return currentNotebook;
        }
    }
    return nil;
}

- (BOOL)networkAvailable
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

- (NSString *)getDirectoryPathForNotebookWithName:(NSString *)notebookName
{
    return [[self getNotebooksRootDirectoryPath]
            stringByAppendingPathComponent:notebookName];
}

- (NSString *)getNotebooksRootDirectoryPath
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
            stringByAppendingPathComponent: NOTE_NOTEBOOKS_FOLDER];
}

- (NSArray *)getDirectoryContentForPath:(NSString *)path
{
    NSError *error;
    NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    if(error)
    {
        @throw [NSException exceptionWithName:DIRECTORY_NOT_FOUND_EXCEPTION reason:error.description userInfo:nil];
    }
    return content;
}

- (NSString *)getTempDirectoryPath
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
            stringByAppendingPathComponent:TEMP_FOLDER];
}

- (void)deleteItemAtPath:(NSString *)path
{
    NSError *error;
    BOOL isSuccessful = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    
    if(!isSuccessful)
    {
        @throw [NSException exceptionWithName:FILE_NOT_FOUND_EXCEPTION reason:error.description userInfo:nil];
    }
}

- (void)createFolderAtPath:(NSString *)path
{
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

#pragma mark -
#pragma mark Public methods

- (NSString *)getNoteDirectoryPathForNote:(Note *)note inNotebookWithName:(NSString *)notebookName
{
    return [[self getDirectoryPathForNotebookWithName:notebookName]
            stringByAppendingPathComponent:note.name];
}

- (void)deleteTempFolder
{
    [self deleteItemAtPath:[self getTempDirectoryPath]];
}

- (void)createTempFolder
{
    [self createFolderAtPath:[self getTempDirectoryPath]];
}

- (void)exchangeNoteAtIndex:(NSInteger)firstIndex withNoteAtIndex:(NSInteger)secondIndex fromNotebook:(NSString *)notebookName
{
    NSMutableArray *array = [self.notebookDictionary objectForKey:notebookName];
    [array exchangeObjectAtIndex:firstIndex withObjectAtIndex:secondIndex];
    [self.notebookDictionary setObject:array forKey:notebookName];
}

- (Notebook *)notebookContainingNote:(Note *)note
{
    for (Notebook *currentNotebook in self.notebookList)
    {
        NSArray *notes = [self getNoteListForNotebook:currentNotebook];
        for (Note *currentNote in notes) {
            if (currentNote == note) {
                return currentNotebook;
            }
        }
    }
    return nil;
}

- (NSArray *)getAllNotes
{
    NSMutableArray *allNotes = [[NSMutableArray alloc] init];
    NSArray *allNotebooks = [self getNotebookList];
    for (Notebook *currentNotebook in allNotebooks) {
        [allNotes addObjectsFromArray:[self getNoteListForNotebook:currentNotebook]];
    }
    return allNotes;
}

- (NSURL *)getBaseURLforNote:(Note *)note inNotebook:(Notebook *)notebook
{
    return [self getBaseURLforNote:note inNotebookWithName:notebook.name];
}

- (NSURL *)getBaseURLforNote:(Note *)note inNotebookWithName:(NSString *)notebookName
{
    NSString *loadedFilePath;
    if(note.name.length > 0)
    {
        loadedFilePath = [self getNoteDirectoryPathForNote:note inNotebookWithName:notebookName];
    }
    else
    {
        loadedFilePath = [self getTempDirectoryPath];
    }
    
    return [NSURL fileURLWithPath:loadedFilePath];
}

- (NSString *)saveImage:(NSDictionary *)imageInfo withName:(NSString *)imageName forNote:(Note *)note inNotebook:(Notebook *)notebook;
{
    return [self saveImage:imageInfo withName:imageName forNote:note  inNotebookWithName:notebook.name];
}

- (NSString *)saveImage:(NSDictionary *)imageInfo withName:(NSString *)imageName forNote:(Note *)note inNotebookWithName:(NSString *)notebookName
{
    NSURL *baseURL = [[self getBaseURLforNote:note inNotebookWithName:notebookName] URLByAppendingPathComponent:imageName];
    NSString *mediaType = [imageInfo objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:PUBLIC_IMAGE_IDENTIFIER])
    {
        UIImage *image = [imageInfo objectForKey:UIImagePickerControllerOriginalImage];
        NSData *data = UIImagePNGRepresentation(image);
        [data writeToURL:baseURL atomically:YES];
    }
    return baseURL.description;
}

- (NSString *)saveUIImage:(UIImage *)image withName:(NSString *)imageName forNote:(Note *)note inNotebookWithName:(NSString *)notebookName
{
    NSURL *baseURL = [[self getBaseURLforNote:note inNotebookWithName:notebookName] URLByAppendingPathComponent:imageName];
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToURL:baseURL atomically:YES];
    return baseURL.description;
}

- (void)syncNotesInNotebook:(Notebook *)notebook
{
    /**
     Notebook clicked from LeftPanelViewController
     -> sync Dropbox and Local
     -> display progress
     -> send notification to ViewController to display the notebook when synchronization is finished
     */
    [self.dropboxManager requestNoteListForNotebook:notebook];
    [self.localManager requestNoteListForNotebook:notebook];
}

#pragma mark -
#pragma mark Note delegates

- (void)addNote:(Note *)newNote toNotebook:(Notebook *)notebook
{
    [self.localManager addNote:newNote toNotebook:notebook];
    if([self networkAvailable])
    {
        [self.dropboxManager addNote:newNote toNotebook:notebook];
    }
}

- (void)addNote:(Note *)newNote toNotebookWithName:(NSString *)notebookName
{
    if(newNote == nil || notebookName == nil)
    {
        return;
    }
    
    if([self noteExists:newNote inNotebookWithName:notebookName] == NO)
    {
        NSMutableArray *array = [self.notebookDictionary objectForKey:notebookName];
        [array addObject:newNote];
    }
    
    [self.localManager addNote:newNote toNotebookWithName:notebookName];
    if([self networkAvailable])
    {
        [self.dropboxManager addNote:newNote toNotebookWithName:notebookName];
    }
}

- (void)removeNote:(Note *)note fromNotebook:(Notebook *)notebook
{
    [self removeNote:note fromNotebookWithName:notebook.name];
}

- (void)removeNote:(Note *)note fromNotebookWithName:(NSString *)notebookName
{
    if(note == nil || notebookName == nil)
    {
        return;
    }
    [[self.notebookDictionary objectForKey:notebookName] removeObject:note];
    [self.localManager removeNote:note fromNotebookWithName:notebookName];
    if([self networkAvailable])
    {
        [self.dropboxManager removeNote:note fromNotebookWithName:notebookName];
    }
}

- (void)renameNote:(Note *)note fromNotebook:(Notebook *)notebook oldName:(NSString *)oldName
{
    [self.localManager renameNote:note fromNotebook:notebook oldName:oldName];
    if([self networkAvailable])
    {
        [self.dropboxManager renameNote:note fromNotebook:notebook oldName:oldName];
    }
}

- (void)renameNote:(Note *)note fromNotebookWithName:(NSString *)notebookName oldName:(NSString *)oldName
{
    [self.localManager renameNote:note fromNotebookWithName:notebookName oldName:oldName];
    if([self networkAvailable])
    {
        [self.dropboxManager renameNote:note fromNotebookWithName:notebookName oldName:oldName];
    }
}

- (NSArray *)getNoteListForNotebook:(Notebook *)notebook
{
    if(notebook)
    {
        if(!notebook.isLoaded)
        {
            [self.localManager requestNoteListForNotebook:notebook];
            notebook.isLoaded = YES;
        }
        return [self.notebookDictionary objectForKey:notebook.name];
    }
    return nil;
}

- (NSArray *)getNoteListForNotebookWithName:(NSString *)notebookName
{
    Notebook *notebook = [self getNotebookWithName:notebookName];
    NSArray *noteList = [self getNoteListForNotebook:notebook];
    return noteList;
}

- (void)requestNoteListForNotebook:(Notebook *)notebook
{
    [self requestNoteListForNotebookWithName:notebook.name];
}

- (void)requestNoteListForNotebookWithName:(NSString *)notebookName
{
    [self.localManager requestNoteListForNotebookWithName:notebookName];
  //  [self.dropboxManager requestNoteListForNotebookWithName:notebookName];
}

#pragma mark -
#pragma mark Notebook delegates

- (void)addNotebook:(Notebook *)newNotebook
{
    if(newNotebook == nil || [self.notebookDictionary objectForKey:newNotebook.name] != nil)
    {
        return;
    }
    
    [self.notebookDictionary setObject:[[NSMutableArray alloc] init] forKey:newNotebook.name];
    [self.notebookList addObject:newNotebook];
    
    [self.localManager addNotebook:newNotebook];
    if([self networkAvailable])
    {
        [self.dropboxManager addNotebook:newNotebook];
    }
}

- (void)addNotebookWithName:(NSString *) notebookName
{
    [self.localManager addNotebookWithName:notebookName];
    if([self networkAvailable])
    {
        [self.dropboxManager addNotebookWithName:notebookName];
    }
}

- (void)removeNotebook:(Notebook *)notebook
{
    [self.localManager removeNotebook:notebook];
    if([self networkAvailable])
    {
        [self.dropboxManager removeNotebook:notebook];
    }
}

- (void)removeNotebookWithName:(NSString *)notebookName
{
    [self removeNotebookFromAllLists:notebookName];
    [self.localManager removeNotebookWithName:notebookName];
    if([self networkAvailable])
    {
        [self.dropboxManager removeNotebookWithName:notebookName];
    }
}

- (void)renameNotebook:(Notebook *)notebook newName:(NSString *)newName
{
    [self.localManager renameNotebook:notebook newName:newName];
    if([self networkAvailable])
    {
        [self.dropboxManager renameNotebook:notebook newName:newName];
    }
}

- (void)renameNotebookWithName:(NSString *)oldName newName:(NSString *)newName
{
    [self.notebookDictionary setObject:[self.notebookDictionary objectForKey:oldName] forKey:newName];
    [self.notebookDictionary removeObjectForKey:oldName];
    
    [self getNotebookWithName:oldName].name = newName;
    
    [self.localManager renameNotebookWithName:oldName newName:newName];
    if([self networkAvailable])
    {
        [self.dropboxManager renameNotebookWithName:oldName newName:newName];
    }
}

- (NSArray *)getNotebookList
{
    [self.dropboxManager getNotebookList];
    if(self.notebookList.count == 0)
    {
        [self.localManager requestNotebookList];
    }
    return self.notebookList;
}

- (void)requestNotebookList
{
    [self.localManager requestNotebookList];
}

#pragma mark -
#pragma mark ResponseHandler

- (void)handleResponseWithNotebookList:(NSArray *) notebookList
{
    [self.notebookList addObjectsFromArray:notebookList];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTEBOOK_LIST_CHANGED object:nil userInfo:nil];
    });
    for (Notebook *currentNotebook in self.notebookList)
    {
        @synchronized (self)
        {
            [self requestNoteListForNotebook:currentNotebook];
        }
        
    }
}

- (NSArray *)getContentsOfNote:(Note *)note inNotebook:(Notebook *)notebook
{
    @throw [NSException exceptionWithName:NOT_IMPLEMENTED_EXCEPTION reason:nil userInfo:nil];
}

- (void)handleResponseWithNoteList:(NSArray *)noteList fromNotebook:(Notebook *)notebook fromManager:(id)manager
{
    [self handleResponseWithNoteList:noteList fromNotebookWithName:notebook.name fromManager:manager];
}

- (void)handleResponseWithNoteList:(NSArray *)noteList fromNotebookWithName:(NSString *)notebookName fromManager:(id)manager
{
    if(manager == self.dropboxManager)
    {
        self.dropboxDataLoaded = YES;
        [self.dropboxNotebookDictionary setObject:noteList forKey:notebookName];
    }
    if(manager == self.localManager)
    {
        self.localDataLoaded = YES;
        [self.localNotebookDictionary setObject:noteList forKey:notebookName];
    }
    if(self.localDataLoaded && self.dropboxDataLoaded)
    {
        [self mergeNotesInNotebookWithName:notebookName];
        self.dropboxDataLoaded = NO;
        self.localDataLoaded = NO;
    }
}

- (void)handleResponseWithNote:(Note *)note notebook:(Notebook *)notebook
{
    @throw [NSException exceptionWithName:NOT_IMPLEMENTED_EXCEPTION reason:nil userInfo:nil];
}

- (void)handleResponseWithNoteContents:(NSData *)contents note:(Note *)note notebook:(Notebook *)notebook
{
    @throw [NSException exceptionWithName:NOT_IMPLEMENTED_EXCEPTION reason:nil userInfo:nil];
}

#pragma mark -
#pragma mark Synchronization merging

- (void)mergeNotesInNotebookWithName:(NSString *)notebookName
{
    NSArray *localNotes = [self.localNotebookDictionary objectForKey:notebookName];
    NSArray *dropboxNotes = [self.dropboxNotebookDictionary objectForKey:notebookName];
    DateTimeManager *dateTimeManager = [[DateTimeManager alloc] init];
    
    for (Note *localNote in localNotes)
    {
        NSString *dropboxDateModified = [self dateModifiedOfNote:localNote.name fromNotebook:notebookName fromStorage:DROPBOX_STORAGE];
        if(dropboxDateModified == nil)
        {
            /** localNote is missing in dropbox
             check if localNote is being deleted
             if it's been deleted
             [self removeNoteWithName:localNote.name fromNotebook:notebookName fromStorage:LOCAL_STORAGE];
             else
             [self addNoteWithName:localNote.name toNotebook:notebookName inStorage:DROPBOX_STORAGE]; */
            continue;
        }
        NSComparisonResult comparisonResult = [dateTimeManager compareStringDate:localNote.dateModified andDate:dropboxDateModified];
        if(comparisonResult == NSOrderedAscending)
        {
            /**  dropbox is latest */
            [self removeNoteWithName:localNote.name fromNotebook:notebookName fromStorage:LOCAL_STORAGE];
            Note *noteToAdd = [self referenceToNoteWithName:localNote.name inNotebook:notebookName fromStorage:DROPBOX_STORAGE];
            [self.localManager addNote:noteToAdd toNotebookWithName:notebookName];
        }
        if(comparisonResult == NSOrderedDescending)
        {
            /** local is latest */
            [self removeNoteWithName:localNote.name fromNotebook:notebookName fromStorage:DROPBOX_STORAGE];
            Note *noteToAdd = [self referenceToNoteWithName:localNote.name inNotebook:notebookName fromStorage:LOCAL_STORAGE];
            [self.dropboxManager addNote:noteToAdd toNotebookWithName:notebookName];
        }
    }
    
    for (Note *dropboxNote in dropboxNotes)
    {
        NSString *localDateModified = [self dateModifiedOfNote:dropboxNote.name fromNotebook:notebookName fromStorage:LOCAL_STORAGE];
        if(localDateModified == nil)
        {
            /** dropboxNote is missing in local
             check if dropboxNote is being deleted
             if it's been deleted
             [self removeNotWithName:dropboxNote.name fromNotebook:notebookName fromStorage:DROPBOX_STORAGE];
             else
             [self addNoteWithName:dropboxNote.name toNotebook:notebookName inStorage:LOCAL_STORAGE]; */
            continue;
        }
        NSComparisonResult comparisonResult = [dateTimeManager compareStringDate:localDateModified andDate:dropboxNote.dateModified];
        if(comparisonResult == NSOrderedAscending)
        {
            /** dropbox is latest */
            [self removeNoteWithName:dropboxNote.name fromNotebook:notebookName fromStorage:LOCAL_STORAGE];
            Note *noteToAdd = [self referenceToNoteWithName:dropboxNote.name inNotebook:notebookName fromStorage:DROPBOX_STORAGE];
            [self.localManager addNote:noteToAdd toNotebookWithName:notebookName];
        }
        if(comparisonResult == NSOrderedDescending)
        {
            /** local is latest */
            [self removeNoteWithName:dropboxNote.name fromNotebook:notebookName fromStorage:DROPBOX_STORAGE];
            Note *noteToAdd = [self referenceToNoteWithName:dropboxNote.name inNotebook:notebookName fromStorage:LOCAL_STORAGE];
            [self.dropboxManager addNote:noteToAdd toNotebookWithName:notebookName];
        }
    }
}

- (NSString *)dateModifiedOfNote:(NSString *)noteName fromNotebook:(NSString *)notebookName fromStorage:(NSString *)storage
{
    return [self referenceToNoteWithName:noteName inNotebook:notebookName fromStorage:storage].dateModified;
}

- (void)removeNoteWithName:(NSString *)noteName fromNotebook:(NSString *)notebookName fromStorage:(NSString *)storage
{
    Note *noteToRemove = [self referenceToNoteWithName:noteName inNotebook:notebookName fromStorage:storage];
    if([storage isEqualToString:LOCAL_STORAGE])
    {
        [self.localManager removeNote:noteToRemove fromNotebookWithName:notebookName];
    }
    if([storage isEqualToString:DROPBOX_STORAGE])
    {
        [self.dropboxManager removeNote:noteToRemove fromNotebookWithName:notebookName];
    }
}

- (void)addNoteWithName:(NSString *)noteName toNotebook:(NSString *)notebookName inStorage:(NSString *)storage
{
    Note *noteToAdd = [self referenceToNoteWithName:noteName inNotebook:notebookName fromStorage:storage];
    if([storage isEqualToString:LOCAL_STORAGE])
    {
        [self.localManager addNote:noteToAdd toNotebookWithName:notebookName];
    }
    if([storage isEqualToString:DROPBOX_STORAGE])
    {
        [self.dropboxManager addNote:noteToAdd toNotebookWithName:notebookName];
    }
    
}

- (Note *)referenceToNoteWithName:(NSString *)noteName inNotebook:(NSString *)notebook fromStorage:(NSString *)storage
{
    NSArray *notesArray;
    if([storage isEqualToString:LOCAL_STORAGE])
    {
        notesArray = [self.localNotebookDictionary objectForKey:notebook];
    }
    if([storage isEqualToString:DROPBOX_STORAGE])
    {
        //notesArray = [self.dropboxNotebookDictionary objectForKey:notebook];
    }
    for (Note *currentNote in notesArray)
    {
        if(currentNote.name == noteName)
        {
            return currentNote;
        }
    }
    return nil;
}

@end
