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

@interface NoteManager()
@property (nonatomic, strong) LocalNoteManager *localManager;
@property (nonatomic, strong) DropboxNoteManager *dropboxManager;
@property TagsParser *tagParser;
@property NSMutableDictionary *notebookDictionary;
@property (nonatomic) NSMutableArray *notebooks;
@end

@implementation NoteManager

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.localManager = [[LocalNoteManager alloc] init];
        self.dropboxManager = [[DropboxNoteManager alloc] initWithManager:self];
        self.notebookDictionary = [[NSMutableDictionary alloc] init];
        self.notebooks = [[NSMutableArray alloc] init];
        self.tagParser = [[TagsParser alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchronize) name:SYNCHRONIZATION object:nil];
    }
    return self;
}

- (void)synchronize
{
    NSArray *localNotebooks = [self.localManager notebookList];
    NSArray *dropboxNotebooks = [self.dropboxManager notebookList];
    
    for (Notebook *currentNotebook in localNotebooks)
    {
        if(![dropboxNotebooks containsObject:currentNotebook])
        {
            [self.dropboxManager addNotebook:currentNotebook];
        }
        [self synchronizeNotesInNotebook:currentNotebook];
    }
    
    for (Notebook *currentNotebook in dropboxNotebooks)
    {
        if(![localNotebooks containsObject:currentNotebook])
        {
            [self.localManager addNotebook:currentNotebook];
        }
        [self synchronizeNotesInNotebook:currentNotebook];
    }
}

- (void)synchronizeNotesInNotebook:(Notebook *)notebook
{
    NSArray *currentNotebookLocalNotes = [self.localManager noteListForNotebook:notebook];
    NSArray *currentNotebookDropboxNotes = [self.dropboxManager noteListForNotebook:notebook];
    for (Note *currentNote in currentNotebookLocalNotes) {
        if(![currentNotebookDropboxNotes containsObject:currentNote])
        {
            [self.dropboxManager addNote:currentNote toNotebook:notebook];
        }
    }
    for (Note *currentNote in currentNotebookDropboxNotes) {
        if(![currentNotebookLocalNotes containsObject:currentNote])
        {
            [self.localManager addNote:currentNote toNotebook:notebook];
        }
    }
}

- (void)removeNotebookFromAllLists:(NSString *)notebookName
{
    [self.notebookDictionary removeObjectForKey:notebookName];
    [self.notebooks removeObject:[self notebookWithName:notebookName]];
}

- (NSArray *)notebookNamesList
{
    return self.notebookDictionary.allKeys;
}

- (BOOL)noteExists:(Note *)newNote inNotebookWithName:(NSString *)notebookName
{
    NSMutableArray *noteList = [[NSMutableArray alloc]initWithArray:[self noteListForNotebookWithName:notebookName]];
    for(Note *note in noteList)
    {
        if([note.name isEqualToString:newNote.name])
        {
            return YES;
            break;
        }
    }
    return NO;
}

- (Notebook *)notebookWithName:(NSString *)notebookName
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

- (NSString *)directoryPathForNotebookWithName:(NSString *)notebookName
{
    return [[self notebooksRootDirectoryPath]
            stringByAppendingPathComponent:notebookName];
}

- (NSString *)notebooksRootDirectoryPath
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
            stringByAppendingPathComponent: NOTE_NOTEBOOKS_FOLDER];
}

- (NSArray *)directoryContentForPath:(NSString *)path
{
    NSError *error;
    NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    
    if(error)
    {
        @throw [NSException exceptionWithName:DIRECTORY_NOT_FOUND_EXCEPTION
                                       reason:error.description
                                     userInfo:nil];
    }
    
    return content;
}

- (NSString *)tempDirectoryPath
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
        @throw [NSException exceptionWithName:FILE_NOT_FOUND_EXCEPTION
                                       reason:error.description
                                     userInfo:nil];
    }
}

- (void)createFoldarAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

#pragma mark -
#pragma mark Public methods

- (NSString *)noteDirectoryPathForNote:(Note *)note inNotebookWithName:(NSString *)notebookName
{
    return [[self directoryPathForNotebookWithName:notebookName]
            stringByAppendingPathComponent:note.name];
}

- (void)deleteTempFolder
{
    NSString *tempDirectory = [self tempDirectoryPath];
    @try
    {
        [self deleteItemAtPath:tempDirectory];
    } @catch (NSException *exception) {
        
    }
}

- (void)createTempFolder
{
    NSString *tempDirectory = [self tempDirectoryPath];
    [self createFoldarAtPath:tempDirectory];
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
        NSArray *notes = [self noteListForNotebook:currentNotebook];
        for (Note *currentNote in notes) {
            if (currentNote == note) {
                return currentNotebook;
            }
        }
    }
    return nil;
}

- (NSArray *)allNotes
{
    NSMutableArray *allNotes = [[NSMutableArray alloc] init];
    NSArray *allNotebooks = [self notebookList];
    for (Notebook *currentNotebook in allNotebooks) {
        [allNotes addObjectsFromArray:[self noteListForNotebook:currentNotebook]];
    }
    return allNotes;
}

- (NSURL *)baseURLforNote:(Note *)note inNotebook:(Notebook *)notebook
{
    return [self baseURLforNote:note inNotebookWithName:notebook.name];
}

- (NSURL *)baseURLforNote:(Note *)note inNotebookWithName:(NSString *)notebookName
{
    NSString *loadedFilePath;
    if(note.name.length > 0)
    {
        loadedFilePath = [self noteDirectoryPathForNote:note inNotebookWithName:notebookName];
    }
    else
    {
        loadedFilePath = [self tempDirectoryPath];
    }
    
    NSURL *baseURL = [NSURL fileURLWithPath:loadedFilePath];
    return baseURL;
}

- (NSString *)saveImage:(NSDictionary *)imageInfo withName:(NSString *)imageName forNote:(Note *)note inNotebook:(Notebook *)notebook;
{
    return [self saveImage:imageInfo withName:imageName forNote:note  inNotebookWithName:notebook.name];
}

- (NSString *)saveImage:(NSDictionary *)imageInfo withName:(NSString *)imageName forNote:(Note *)note inNotebookWithName:(NSString *)notebookName
{
    NSURL *baseURL = [[self baseURLforNote:note inNotebookWithName:notebookName] URLByAppendingPathComponent:imageName];
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
    NSURL *baseURL = [[self baseURLforNote:note inNotebookWithName:notebookName] URLByAppendingPathComponent:imageName];
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToURL:baseURL atomically:YES];
    return baseURL.description;
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
    
    if(![self noteExists:newNote inNotebookWithName:notebookName])
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

- (void)removeNote:(Note *)note fromNotebook:(Notebook *)notebookName
{
    [self.localManager removeNote:note fromNotebook:notebookName];
    
    NSMutableArray *array = [self.notebookDictionary objectForKey:notebookName.name];
    [array removeObject:note];
    
    if([self networkAvailable])
    {
        [self.dropboxManager removeNote:note fromNotebook:notebookName];
    }
}

- (void)removeNote:(Note *)note fromNotebookWithName:(NSString *)notebookName
{
    if(note == nil || notebookName == nil)
    {
        return;
    }
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

- (NSArray *)noteListForNotebook:(Notebook *)notebook
{
    NSArray *array = nil;
    if(notebook)
    {
        if(!notebook.isLoaded)
        {
            NSArray *notes = [self.localManager noteListForNotebook:notebook];
            NSMutableArray *loaddedNotes = [[NSMutableArray alloc] initWithArray:notes];
            [self.notebookDictionary setObject:loaddedNotes forKey:notebook.name];
            notebook.isLoaded = YES;
        }
        array = [self.notebookDictionary objectForKey:notebook.name];
    }
    return array;
}

- (NSArray *)noteListForNotebookWithName:(NSString *)notebookName
{
    Notebook *notebook = [self notebookWithName:notebookName];
    NSArray *noteList = [self noteListForNotebook:notebook];
    return noteList;
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
    [self.notebooks addObject:newNotebook];
    
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
    
    [self notebookWithName:oldName].name = newName;
    
    [self.localManager renameNotebookWithName:oldName newName:newName];
    if([self networkAvailable])
    {
        [self.dropboxManager renameNotebookWithName:oldName newName:newName];
    }
}

- (NSArray *)notebookList
{
    [self.dropboxManager notebookList];
    [self.notebooks addObjectsFromArray:[self.localManager notebookList]];
    return self.notebookList;
}

@end
