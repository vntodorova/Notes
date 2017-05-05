//
//  LocalNoteManager.m
//  Notes
//
//  Created by VCS on 4/6/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "LocalNoteManager.h"
#import "Defines.h"
#import "Notebook.h"
#import "Note.h"
#import "TagsParser.h"

@interface LocalNoteManager()
@property (assign, nonatomic) NSObject<ResponseHandler>* responseHandler;
@property TagsParser *tagParser;
@end

@implementation LocalNoteManager

- (instancetype)initWithResponseHandler:(NSObject<ResponseHandler>*)responseHandler
{
    self = [super init];
    if (self)
    {
        self.tagParser = [[TagsParser alloc] init];
        self.responseHandler = responseHandler;
        [self createDirectoryAtPath: [self getNotebooksRootDirectoryPath]];
        [self loadNotebooks];
    }
    return self;
}

- (void)deleteItemAtPath:(NSString *)path
{
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (NSString *)getTempDirectoryPath
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
            stringByAppendingPathComponent:TEMP_FOLDER];
}

- (NSString *)getNotebooksRootDirectoryPath
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
            stringByAppendingPathComponent: NOTE_NOTEBOOKS_FOLDER];
}

- (NSString *)getDirectoryPathForNotebookWithName: (NSString*) notebookName
{
    return [[self getNotebooksRootDirectoryPath]
            stringByAppendingPathComponent:notebookName];
}

- (NSString *)getDirectoryPathForNote:(Note *)note inNotebookWithName:(NSString *)notebookName
{
    return [[self getDirectoryPathForNotebookWithName:notebookName]
            stringByAppendingPathComponent:note.name];
}

- (void)saveToDisk:(Note *)newNote toNotebook:(NSString *)notebookName
{
    NSString *noteRoot = [self getDirectoryPathForNote:newNote inNotebookWithName:notebookName];
    
    [self createDirectoryAtPath:noteRoot];
    
    [self saveData:[self.tagParser buildTextFromTags:newNote.tags] toFile:[noteRoot stringByAppendingPathComponent:NOTE_TAGS_FILE]];
    [self saveData:newNote.body toFile:[noteRoot stringByAppendingPathComponent:NOTE_BODY_FILE]];
    [self saveData:newNote.triggerDate toFile:[noteRoot stringByAppendingPathComponent:NOTE_TRIGGER_DATE_FILE]];
    [self copyFilesFromSource:[self getTempDirectoryPath] toDestination:noteRoot];
}

- (void)copyFilesFromSource:(NSString *)source toDestination:(NSString *)destination
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSEnumerator *directoryContents = [[NSFileManager defaultManager] enumeratorAtPath:source];
    NSString *fileName;
    while(fileName = [directoryContents nextObject])
    {
        if([self isHidden:fileName] == NO)
        {
            NSString *fileSourcePath = [source stringByAppendingPathComponent:fileName];
            NSString *fileDestinationPath = [destination stringByAppendingPathComponent:fileName];
            
            [fileManager copyItemAtPath:fileSourcePath toPath:fileDestinationPath error:nil];
        }
    }
}

- (void)saveData:(NSString *)fileContent toFile:(NSString *)path
{
    [fileContent writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)createDirectoryAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path isDirectory:nil] == NO)
    {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSArray *)loadNotebooks
{
    NSArray *directoryContents = [self getDirectoryContentForPath: [self getNotebooksRootDirectoryPath]];
    NSMutableArray *notebooksList = [[NSMutableArray alloc] init];
    
    for (NSString *fileName in directoryContents)
    {
        Notebook *loadedNotebook = [[Notebook alloc] initWithName:fileName];
        if([self isHidden:loadedNotebook.name] == NO)
        {
            loadedNotebook.notesCount = [self notesForNotebookWithName:loadedNotebook.name].count;
            [notebooksList addObject:loadedNotebook];
        }
    }
    return notebooksList;
}

- (NSMutableArray *)notesForNotebookWithName:(NSString *)notebookName
{
    NSString *path = [self getDirectoryPathForNotebookWithName:notebookName];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSArray *directoryContents = [self getDirectoryContentForPath: path];
    
    for(NSString *noteName in directoryContents)
    {
        if([self isHidden:noteName] == NO)
        {
            NSString *notePath = [path stringByAppendingPathComponent:noteName];
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
        @throw [NSException exceptionWithName:DIRECTORY_NOT_FOUND_EXCEPTION reason:error.description userInfo:nil];
    }
    return content;
}

- (Note *)loadNoteWithPath:(NSString *)notePath andName:(NSString*) noteName
{
    Note *note = [[Note alloc] init];
    
    note.name = noteName;
    note.body = [self loadDataFromFilePath:[notePath stringByAppendingPathComponent:NOTE_BODY_FILE]];
    NSError *error;
    NSDictionary* noteFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[notePath stringByAppendingPathComponent:NOTE_BODY_FILE] error:&error];
    NSDate *noteFileDateModified = [noteFileAttributes objectForKey:NSFileModificationDate];
    
    note.dateModified = noteFileDateModified.description;
    note.triggerDate = [self loadDataFromFilePath:[notePath stringByAppendingPathComponent:NOTE_TRIGGER_DATE_FILE]];
    
    NSString *tags = [self loadDataFromFilePath:[notePath stringByAppendingPathComponent:NOTE_TAGS_FILE]];
    note.tags = [self.tagParser getTagsFromText:tags];
    return note;
}

- (NSString *)loadDataFromFilePath:(NSString *)path
{
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

- (BOOL)isHidden:(NSString *)fileName
{
    return [fileName hasPrefix:@"."];
}

#pragma mark -
#pragma mark Note manager delegate

- (void)addNote:(Note *)newNote toNotebook:(Notebook *)notebook
{
    [self addNote:newNote toNotebookWithName:notebook.name];
}

- (void)addNote:(Note *)newNote toNotebookWithName:(NSString *)notebookName
{
    [self saveToDisk:newNote toNotebook:notebookName];
    [self requestNoteListForNotebookWithName:notebookName];
}

- (void)removeNote:(Note *)note fromNotebook:(Notebook *)notebook
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self removeNote:note fromNotebookWithName:notebook.name];
    });
}

- (void)removeNote:(Note *)note fromNotebookWithName:(NSString *)notebookName
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self deleteItemAtPath:[self getDirectoryPathForNote:note inNotebookWithName:notebookName]];
    });
}

- (void)renameNote:(Note *)note fromNotebook:(Notebook*) notebook oldName:(NSString*) oldName
{
    [self renameNote:note fromNotebookWithName:notebook.name oldName:oldName];
}

- (void)renameNote:(Note *)note fromNotebookWithName:(NSString *)notebookName oldName:(NSString *)oldName
{
    Note *dummyNote = [[Note alloc] init];
    dummyNote.name = oldName;
        
    NSString *oldPath = [self getDirectoryPathForNote:dummyNote inNotebookWithName:notebookName];
    NSString *newPath = [[self getDirectoryPathForNotebookWithName:notebookName] stringByAppendingPathComponent:note.name];
    [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:nil];
}

- (void)copyNote:(Note *)note fromNotebook:(Notebook *)source toNotebook:(Notebook *)destination
{
    [self copyNote:note fromNotebookWithName:source.name toNotebookWithName:destination.name];
}

- (void)copyNote:(Note *)note fromNotebookWithName:(NSString *)source toNotebookWithName:(NSString *)destination
{
    NSString *sourcePath = [self getDirectoryPathForNote:note inNotebookWithName:source];
    NSString *destinationPath = [self getDirectoryPathForNote:note inNotebookWithName:destination];
    [self deleteItemAtPath:destinationPath];
    [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:nil];
}

- (void)requestNoteListForNotebook:(Notebook *)notebook
{
    [self requestNoteListForNotebookWithName:notebook.name];
}

- (void)requestNoteListForNotebookWithName:(NSString *)notebookName
{
    if([self isHidden:notebookName] == NO)
    {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                       {
                           [self.responseHandler handleResponseWithNoteList:[self notesForNotebookWithName:notebookName] fromNotebookWithName:notebookName fromManager:self];
                       });
    }
}

#pragma mark -
#pragma mark Notebook manager delegate

- (void)addNotebook:(Notebook *)newNotebook
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self createDirectoryAtPath:[self getDirectoryPathForNotebookWithName:newNotebook.name]];
    });
}

- (void)addNotebookWithName:(NSString *)notebookName
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self addNotebook:[[Notebook alloc] initWithName:notebookName]];
    });
}

- (void)removeNotebook:(Notebook *)notebook
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self removeNotebookWithName:notebook.name];
    });
}

- (void)removeNotebookWithName:(NSString *)notebookName
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self deleteItemAtPath:[self getDirectoryPathForNotebookWithName:notebookName]];
    });
}

- (void)renameNotebook:(Notebook *)notebook newName:(NSString *)newName
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self renameNotebookWithName:notebook.name newName:newName];
    });
}

- (void)renameNotebookWithName:(NSString *)oldName newName:(NSString *)newName
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [[NSFileManager defaultManager] moveItemAtPath:[self getDirectoryPathForNotebookWithName:oldName]
                                                toPath:[self getDirectoryPathForNotebookWithName:newName]
                                                 error:nil];
    });
}

- (void)requestNotebookList
{
    NSLog(@"LocalManager : requested notebook list");
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self.responseHandler handleResponseWithNotebookList:[self loadNotebooks] fromManager:self];
    });
}

@end
