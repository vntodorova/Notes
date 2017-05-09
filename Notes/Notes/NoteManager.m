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

- (BOOL)container:(NSArray *)container hasNotebookWithName:(NSString *)notebookName
{
    for (Notebook *currentNotebook in container)
    {
        if([currentNotebook.name isEqualToString: notebookName])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)notebookWithName:(NSString *)notebookName hasNote:(Note *)note
{
    NSArray *noteList = [self getNoteListForNotebookWithName:notebookName];
    for(Note *note in noteList)
    {
        if([note.name isEqualToString:note.name])
        {
            return YES;
        }
    }
    return NO;
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
    [self requestNoteListForNotebookWithName:GENERAL_NOTEBOOK_NAME];
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
    if(newNote && notebookName)
    {
        if([self notebookWithName:notebookName hasNote:newNote] == NO)
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
}

- (void)removeNote:(Note *)note fromNotebook:(Notebook *)notebook
{
    [self removeNote:note fromNotebookWithName:notebook.name];
}

- (void)removeNote:(Note *)note fromNotebookWithName:(NSString *)notebookName
{
    if(note && notebookName)
    {
        [[self.notebookDictionary objectForKey:notebookName] removeObject:note];
        [self.localManager removeNote:note fromNotebookWithName:notebookName];
        if([self networkAvailable])
        {
            [self.dropboxManager removeNote:note fromNotebookWithName:notebookName];
        }
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

- (void)requestNoteListForNotebook:(Notebook *)notebook
{
    [self requestNoteListForNotebookWithName:notebook.name];
}

- (void)requestNoteListForNotebookWithName:(NSString *)notebookName
{
    [self.dropboxManager requestNoteListForNotebookWithName:notebookName];
    [self.localManager requestNoteListForNotebookWithName:notebookName];
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
        NSLog(@"NoteManager : handle notebook list from dropbox");
        self.dropboxNotebookListLoaded = YES;
        self.dropboxNotebookList = [[NSMutableArray alloc] initWithArray:notebookList];
        self.isDropboxNotebookListRequestPending = NO;
    }
    if(manager == self.localManager)
    {
        NSLog(@"NoteManager : handle notebook list from local");
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
        self.localNotebookListLoaded = NO;
        self.dropboxNotebookListLoaded = NO;
    }
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

- (void)handleResponseWithNoteList:(NSArray *)noteList fromNotebook:(Notebook *)notebook fromManager:(id)manager
{
    [self handleResponseWithNoteList:noteList fromNotebookWithName:notebook.name fromManager:manager];
}

#pragma mark -
#pragma mark Synchronization merging

- (void)mergeNotesInNotebookWithName:(NSString *)notebookName
{
    [self syncManagersFirst:self.localManager second:self.dropboxManager forNotebook:notebookName];
    [self syncManagersFirst:self.dropboxManager second:self.localManager forNotebook:notebookName];
    [self.localManager requestNoteListForNotebookWithName:notebookName];
}

- (void)syncManagersFirst:(id)firstManager second:(id)secondManager forNotebook:(NSString *)notebookName
{
    NSArray *notesArray = [self notesForNotebook:notebookName inManager:firstManager];
    for (Note *manager1Note in notesArray)
    {
        NSString *manager2DateModified = [self dateModifiedOfNoteWithName:manager1Note.name fromNotebook:notebookName inManager:secondManager];
        if(manager2DateModified == nil)
        {
            [self addNote:manager1Note fromNotebook:notebookName toManager:secondManager];
            continue;
        }
        NSComparisonResult comparisonResult = [[DateTimeManager sharedInstance] compareStringDate:manager2DateModified andDate:manager1Note.dateModified];
        if(comparisonResult == NSOrderedAscending)
        {
            [self addNote:manager1Note fromNotebook:notebookName toManager:secondManager];
        }
        if(comparisonResult == NSOrderedDescending)
        {
            [self addNote:manager1Note fromNotebook:notebookName toManager:firstManager];
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
        if([self container:self.dropboxNotebookList hasNotebookWithName:currentNotebook.name] == NO)
        {
            NSLog(@"Added %@ to dropbox",currentNotebook.name);
            [self.dropboxManager addNotebook:currentNotebook];
        }
        if([self container:self.notebookList hasNotebookWithName:currentNotebook.name] == NO)
        {
            [self.notebookList addObject:currentNotebook];
        }
    }
    
    for(Notebook *currentNotebook in self.dropboxNotebookList)
    {
        if([self container:self.localNotebookList hasNotebookWithName:currentNotebook.name] == NO)
        {
            NSLog(@"Added %@ to local",currentNotebook.name);
            [self.localManager addNotebook:currentNotebook];
        }
        if([self container:self.notebookList hasNotebookWithName:currentNotebook.name] == NO)
        {
            [self.notebookList addObject:currentNotebook];
        }
    }
    NSLog(@"Finished merging");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTEBOOK_LIST_CHANGED object:nil];
}

@end
