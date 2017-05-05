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

@property BOOL isLocalNotebookListRequestPending;
@property BOOL isDropboxNotebookListRequestPending;

@property BOOL dropboxNotebookListLoaded;
@property BOOL localNotebookListLoaded;

@property NSMutableArray *localNotebookList;
@property NSMutableArray *dropboxNotebookList;

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestNoteListForGeneralNotebook) name:NOTE_DOWNLOADED object:nil];
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
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void)createFolderAtPath:(NSString *)path
{
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)requestNoteListForGeneralNotebook
{
    //[self syncNotesInNotebook:[[Notebook alloc] initWithName:GENERAL_NOTEBOOK_NAME]];
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
     TODO
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
    return [self.notebookDictionary objectForKey:notebookName];
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

- (void)copyNote:(Note *)note fromNotebook:(Notebook *)source toNotebook:(Notebook *)destination
{
    [self copyNote:note fromNotebookWithName:source.name toNotebookWithName:destination.name];
}

- (void)copyNote:(Note *)note fromNotebookWithName:(NSString *)source toNotebookWithName:(NSString *)destination
{
    [self.dropboxManager copyNote:note fromNotebookWithName:source toNotebookWithName:destination];
    [self.localManager copyNote:note fromNotebookWithName:source toNotebookWithName:destination];
    [self addNote:note toNotebookWithName:destination];
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
    return self.notebookList;
}

- (void)requestNotebookList
{
    if(!self.isDropboxNotebookListRequestPending)
    {
        self.isDropboxNotebookListRequestPending = true;
        [self.dropboxManager requestNotebookList];
    }
    if(!self.isLocalNotebookListRequestPending)
    {
        self.isLocalNotebookListRequestPending = true;
        [self.localManager requestNotebookList];
    }
}

#pragma mark -
#pragma mark ResponseHandler

- (void)handleResponseWithNotebookList:(NSArray *)notebookList fromManager:(id)manager;
{
    if(manager == self.dropboxManager)
    {
        self.dropboxNotebookListLoaded = YES;
        self.dropboxNotebookList = [[NSMutableArray alloc] initWithArray:notebookList];
        self.isDropboxNotebookListRequestPending = NO;
    }
    if(manager == self.localManager)
    {
        self.localNotebookListLoaded = YES;
        self.localNotebookList = [[NSMutableArray alloc] initWithArray:notebookList];
        self.notebookList = [NSMutableArray arrayWithArray:notebookList];
        for(Notebook *notebook in notebookList)
        {
            [self.notebookDictionary setObject:[[NSMutableArray alloc]init] forKey: notebook.name];
        }
        self.isLocalNotebookListRequestPending = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTEBOOK_LIST_CHANGED object:nil];
    }
    if(self.dropboxNotebookListLoaded && self.localNotebookListLoaded)
    {
        [self mergeNotebooks];
    }
}

- (NSArray *)getContentsOfNote:(Note *)note inNotebook:(Notebook *)notebook
{
    @throw [NSException exceptionWithName:NOT_IMPLEMENTED_EXCEPTION reason:nil userInfo:nil];
}

- (void)handleResponseWithNoteList:(NSArray *)noteList fromNotebook:(Notebook *)notebook fromManager:(id)manager
{
    @throw [NSException exceptionWithName:NOT_IMPLEMENTED_EXCEPTION reason:nil userInfo:nil];
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
        [self.notebookDictionary setObject:noteList forKey:notebookName];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_LIST_CHANGED object:nil];
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
    [self syncManager1:self.localManager withManager2:self.dropboxManager forNotebook:notebookName];
    [self syncManager1:self.dropboxManager withManager2:self.localManager forNotebook:notebookName];
    [self.localManager requestNoteListForNotebookWithName:notebookName];
}

- (void)syncManager1:(id)manager1 withManager2:(id)manager2 forNotebook:(NSString *)notebookName
{
    NSArray *notesArray = [self notesForNotebook:notebookName inManager:manager1];
    for (Note *manager1Note in notesArray)
    {
        NSString *manager2DateModified = [self dateModifiedOfNoteWithName:manager1Note.name fromNotebook:notebookName inManager:manager2];
        if(manager2DateModified == nil)
        {
            // TODO : check if manager1Note is being deleted : if (it's been deleted) {remove note from manager1} else {add it to manager2}
            [self addNote:manager1Note fromNotebook:notebookName toManager:manager2];
            continue;
        }
        NSComparisonResult comparisonResult = [[DateTimeManager sharedInstance] compareStringDate:manager2DateModified andDate:manager1Note.dateModified];
        if(comparisonResult == NSOrderedAscending)
        {
            [self addNote:manager1Note fromNotebook:notebookName toManager:manager2];
        }
        if(comparisonResult == NSOrderedDescending)
        {
            [self addNote:manager1Note fromNotebook:notebookName toManager:manager1];
        }
    }
}

- (NSArray *)notesForNotebook:(NSString *)notebookName inManager:(id)manager
{
    if(manager == self.localManager)
    {
        return [self.localNotebookDictionary objectForKey:notebookName];
    }
    if(manager == self.dropboxManager)
    {
        return [self.dropboxNotebookDictionary objectForKey:notebookName];
    }
    return nil;
}

- (void)addNote:(Note *)note fromNotebook:(NSString *)notebookName toManager:(id)manager
{
    if(manager == self.localManager)
    {
        [self.dropboxManager downloadNote:note fromNotebookWithName:notebookName];
    }
    if(manager == self.dropboxManager)
    {
        [self.dropboxManager addNote:note toNotebookWithName:notebookName];
    }
}

- (NSString *)dateModifiedOfNoteWithName:(NSString *)noteName fromNotebook:(NSString *)notebookName inManager:(id)manager
{
    NSArray *notesArray = [self notesForNotebook:notebookName inManager:manager];
    
    for (Note *currentNote in notesArray)
    {
        if([currentNote.name isEqualToString: noteName])
        {
            return currentNote.dateModified;
        }
    }
    return nil;
}

- (void)mergeNotebooks
{
    for(Notebook *currentNotebook in self.localNotebookList)
    {
        if(![self.dropboxNotebookList containsObject:currentNotebook])
        {
            [self.dropboxManager addNotebook:currentNotebook];
        }
    }
    
    for(Notebook *currentNotebook in self.dropboxNotebookList)
    {
        if(![self.localNotebookList containsObject:currentNotebook])
        {
            [self.localManager addNotebook:currentNotebook];
        }
    }
}

@end
