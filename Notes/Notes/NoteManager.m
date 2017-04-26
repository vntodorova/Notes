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
@property NSMutableDictionary<NSString*, NSMutableArray<Note*>*> *notebookDictionary;
@property NSMutableArray<Notebook*> *notebookList;
@end

@implementation NoteManager

- (instancetype)initWithLocalManager:(LocalNoteManager *)localManager andDropboxManager:(DropboxNoteManager *)dropboxManager
{
    self = [super init];
    if(self)
    {
        self.localManager = localManager;
        self.dropboxManager = dropboxManager;
        self.notebookDictionary = [[NSMutableDictionary alloc] init];
        self.notebookList = [[NSMutableArray alloc] init];
        self.tagParser = [[TagsParser alloc] init];
        [self createDirectoryAtPath: [self getNotebooksRootDirectoryPath]];
        [self loadNotebooks];
    }
    return self;
}

- (void)loadNotebooks
{
    NSArray *directoryContents = [self getDirectoryContentForPath: [self getNotebooksRootDirectoryPath]];
    
    for(int i = 0; i < directoryContents.count; i++)
    {
        Notebook *loadedNotebook = [[Notebook alloc] initWithName:[directoryContents objectAtIndex:i]];
        BOOL isHidden = [loadedNotebook.name hasPrefix:@"."];
        if(!isHidden)
        {
            [self.notebookList addObject:loadedNotebook];
            [self.notebookDictionary setObject:[[NSMutableArray alloc]init] forKey:loadedNotebook.name];
        }
    }
}

- (void)createDirectoryAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path isDirectory:nil])
    {
        return;
    }
    else
    {
        [self createFoldarAtPath:path];
    }
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

- (NSMutableArray *)loadNotesForNotebook:(Notebook *)notebook
{
    NSString *path = [self getDirectoryPathForNotebookWithName:notebook.name];
    NSMutableArray<Note*> *array = [[NSMutableArray alloc] init];
    
    NSArray *directoryContents = [self getDirectoryContentForPath: path];
    
    for(NSString *noteName in directoryContents)
    {
        BOOL isHidden = [noteName hasPrefix:@"."];
        if(!isHidden)
        {
            NSString *notePath = [NSString stringWithFormat:@"%@/%@",path, noteName];
            [array addObject:[self loadNoteWithPath:notePath andName:noteName]];
        }
    }
    return array;
}

- (NSArray *)getDirectoryContentForPath:(NSString *)path
{
    NSError *error;
    NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    
    if(error)
    {
        @throw [NSException exceptionWithName:@"DirectoryNotFound"
                                       reason:error.description
                                     userInfo:nil];
    }
    
    return content;
}

- (Note *)loadNoteWithPath:(NSString *)notePath andName:(NSString *)noteName
{
    Note *note = [[Note alloc] init];
    
    note.name = noteName;
    note.body = [self loadDataFromFilePath:[NSString stringWithFormat:@"%@/%@",notePath, NOTE_BODY_FILE]];
    note.dateCreated = [self loadDataFromFilePath:[NSString stringWithFormat:@"%@/%@",notePath, NOTE_DATE_FILE]];
    note.triggerDate = [self loadDataFromFilePath:[NSString stringWithFormat:@"%@/%@",notePath, NOTE_TRIGGER_DATE_FILE]];
    
    NSString *tags = [self loadDataFromFilePath:[NSString stringWithFormat:@"%@/%@",notePath, NOTE_TAGS_FILE]];
    note.tags = [self.tagParser getTagsFromText:tags];
    return note;
}

- (NSString *)loadDataFromFilePath:(NSString *)path
{
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    return fileContents;
}

- (Notebook*) getNotebookWithName:(NSString *) notebookName
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
        @throw [NSException exceptionWithName:@"FileNotFoundException"
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

- (NSString *)getNoteDirectoryPathForNote:(Note *)note inNotebookWithName:(NSString *)notebookName
{
    return [[self getDirectoryPathForNotebookWithName:notebookName]
            stringByAppendingPathComponent:note.name];
}

- (void)deleteTempFolder
{
    NSString *tempDirectory = [self getTempDirectoryPath];
    @try
    {
        [self deleteItemAtPath:tempDirectory];
    } @catch (NSException *exception) {
        
    }
}

- (void)createTempFolder
{
    NSString *tempDirectory = [self getTempDirectoryPath];
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
        NSArray *notes = [self getNoteListForNotebook:currentNotebook];
        for (Note *currentNote in notes) {
            if (currentNote == note) {
                return currentNotebook;
            }
        }
    }
    return nil;
}

- (NSArray<Note *> *)getNoteListForNotebook:(Notebook *)notebook
{
    NSArray *array = nil;
    if(notebook)
    {
        if(!notebook.isLoaded)
        {
            NSMutableArray *loaddedNotes = [self loadNotesForNotebook:notebook];
            [self.notebookDictionary setObject:loaddedNotes forKey:notebook.name];
            notebook.isLoaded = YES;
        }
        array = [self.notebookDictionary objectForKey:notebook.name];
    }
    return array;
}

- (NSArray<Note *> *)getNoteListForNotebookWithName:(NSString *)notebookName
{
    Notebook *notebook = [self getNotebookWithName:notebookName];
    NSArray *noteList = [self getNoteListForNotebook:notebook];
    return noteList;
}

- (NSArray<Note *> *)getAllNotes
{
    NSMutableArray *allNotes = [[NSMutableArray alloc] init];
    NSArray *allNotebooks = [self getNotebookList];
    for (Notebook *currentNotebook in allNotebooks) {
        [allNotes addObjectsFromArray:[self getNoteListForNotebook:currentNotebook]];
    }
    return allNotes;
}

- (NSURL*) getBaseURLforNote:(Note*) note inNotebook:(Notebook*) notebook
{
    return [self getBaseURLforNote:note inNotebookWithName:notebook.name];
}

- (NSURL*) getBaseURLforNote:(Note*) note inNotebookWithName:(NSString*) notebookName
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
    
    NSURL *baseURL = [NSURL fileURLWithPath:loadedFilePath];
    return baseURL;
}

- (NSArray<Notebook *> *)getNotebookList
{
    return self.notebookList;
}

- (NSArray *)getNotebookNamesList
{
    return self.notebookDictionary.allKeys;
}

#pragma mark -
#pragma mark Note delegates

- (void)addNote:(Note *)newNote toNotebook:(Notebook *)notebook
{
    [self.localManager addNote:newNote toNotebook:notebook];
    if([self networkAvailable])
    {
        //[self.dropboxManager addNote:newNote toNotebook:notebook];
    }
}

- (void)addNote:(Note *)newNote toNotebookWithName:(NSString *)notebookName
{
    [self.localManager addNote:newNote toNotebookWithName:notebookName];
    if([self networkAvailable])
    {
        //[self.dropboxManager addNote:newNote toNotebookWithName:notebookName];
    }
}

- (void)removeNote:(Note *)note fromNotebook:(Notebook *)notebookName
{
    [self.localManager removeNote:note fromNotebook:notebookName];
    if([self networkAvailable])
    {
        //[self.dropboxManager removeNote:note fromNotebook:notebookName];
    }
}

- (void)removeNote:(Note *)note fromNotebookWithName:(NSString *)notebookName
{
    [self.localManager removeNote:note fromNotebookWithName:notebookName];
    if([self networkAvailable])
    {
        //[self.dropboxManager removeNote:note fromNotebookWithName:notebookName];
    }
}

- (NSString*) saveImage:(NSDictionary*) imageInfo withName:(NSString*)imageName forNote:(Note*) note inNotebook:(Notebook*) notebook
{
    return [self.localManager saveImage:imageInfo withName:imageName forNote:note inNotebook:notebook];
}

- (NSString*) saveImage:(NSDictionary*) imageInfo withName:(NSString*)imageName forNote:(Note*) note inNotebookWithName:(NSString*) notebookName
{
    return [self.localManager saveImage:imageInfo withName:imageName forNote:note inNotebookWithName:notebookName];
}

- (NSString *)saveUIImage:(UIImage *)image withName:(NSString *)imageName forNote:(Note *)note inNotebookWithName:(NSString *)notebookName
{
    return [self.localManager saveUIImage:image withName:imageName forNote:note inNotebookWithName:notebookName];
}

- (void)renameNote:(Note *)note fromNotebook:(Notebook *)notebook oldName:(NSString *)oldName
{
    [self.localManager renameNote:note fromNotebook:notebook oldName:oldName];
    if([self networkAvailable])
    {
        //[self.dropboxManager renameNote:note fromNotebook:notebook oldName:oldName];
    }
}

- (void)renameNote:(Note *)note fromNotebookWithName:(NSString *)notebookName oldName:(NSString *)oldName
{
    [self.localManager renameNote:note fromNotebookWithName:notebookName oldName:oldName];
    if([self networkAvailable])
    {
        //[self.dropboxManager renameNote:note fromNotebookWithName:notebookName oldName:oldName];
    }
}

#pragma mark -
#pragma mark Notebook delegates

- (void)addNotebook:(Notebook *)newNotebook
{
    [self.localManager addNotebook:newNotebook];
    if([self networkAvailable])
    {
        //[self.dropboxManager addNotebook:newNotebook];
    }
}

- (void)addNotebookWithName:(NSString *) notebookName
{
    [self.localManager addNotebookWithName:notebookName];
    if([self networkAvailable])
    {
        //[self.dropboxManager addNotebookWithName:notebookName];
    }
}

- (void)removeNotebook:(Notebook *)notebook
{
    [self.localManager removeNotebook:notebook];
    if([self networkAvailable])
    {
        //[self.dropboxManager removeNotebook:notebook];
    }
}

- (void)removeNotebookWithName:(NSString *)notebookName
{
    [self.localManager removeNotebookWithName:notebookName];
    if([self networkAvailable])
    {
        //[self.dropboxManager removeNotebookWithName:notebookName];
    }
}

- (void)renameNotebook:(Notebook *)notebook newName:(NSString *)newName
{
    [self.localManager renameNotebook:notebook newName:newName];
    if([self networkAvailable])
    {
        //[self.dropboxManager renameNotebook:notebook newName:newName];
    }
}

- (void)renameNotebookWithName:(NSString *)oldName newName:(NSString *)newName
{
    [self.localManager renameNotebookWithName:oldName newName:newName];
    if([self networkAvailable])
    {
        //[self.dropboxManager renameNotebookWithName:oldName newName:newName];
    }
}

@end
