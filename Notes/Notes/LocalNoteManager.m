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
#import "DateTimeManager.h"
#import "TagsParser.h"

@interface LocalNoteManager()

@property TagsParser *tagParser;
@end

@implementation LocalNoteManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.tagParser = [[TagsParser alloc] init];
        [self createDirectoryAtPath: [self notebooksRootDirectoryPath]];
        [self loadNotebooks];
    }
    return self;
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

- (NSString *)tempDirectoryPath
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
            stringByAppendingPathComponent:TEMP_FOLDER];
}

- (NSString *)notebooksRootDirectoryPath
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
            stringByAppendingPathComponent: NOTE_NOTEBOOKS_FOLDER];
}

- (NSString *)directoryPathForNotebookWithName: (NSString*) notebookName
{
    return [[self notebooksRootDirectoryPath]
            stringByAppendingPathComponent:notebookName];
}

- (NSString *)noteDirectoryPathForNote:(Note *)note inNotebookWithName:(NSString *)notebookName
{
    return [[self directoryPathForNotebookWithName:notebookName]
            stringByAppendingPathComponent:note.name];
}

- (void)saveToDisk:(Note *)newNote toNotebook:(NSString *)notebookName
{
    NSString *noteRoot = [self noteDirectoryPathForNote:newNote inNotebookWithName:notebookName];
    
    [self createDirectoryAtPath:noteRoot];
    
    [self saveData:[self.tagParser buildTextFromTags:newNote.tags]  toFile:[noteRoot stringByAppendingPathComponent:NOTE_TAGS_FILE]];
    [self saveData:newNote.body                                     toFile:[noteRoot stringByAppendingPathComponent:NOTE_BODY_FILE]];
    [self saveData:newNote.dateCreated                              toFile:[noteRoot stringByAppendingPathComponent:NOTE_DATE_FILE]];
    [self saveData:newNote.triggerDate                              toFile:[noteRoot stringByAppendingPathComponent:NOTE_TRIGGER_DATE_FILE]];
    
    [self copyFilesFromSource:[self tempDirectoryPath] toDestination:noteRoot];
}

- (void)copyFilesFromSource:(NSString *)source toDestination:(NSString *)destination
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSEnumerator *directoryContents = [self getEnumeratorForDir:source];
    NSString *imageName;
    while(imageName = [directoryContents nextObject])
    {
        BOOL isHidden = [imageName hasPrefix:@"."];
        if(!isHidden)
        {
            NSString *imageSourcePath = [source stringByAppendingPathComponent:imageName];
            NSString *imageDestinationPath = [destination stringByAppendingPathComponent:imageName];
            
            [fileManager copyItemAtPath:imageSourcePath toPath:imageDestinationPath error:nil];
        }
    }
}

- (void)saveData:(NSString *)fileContent toFile:(NSString *)path
{
    NSError *error;
    [fileContent writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
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
        [self createFolderAtPath:path];
    }
}

- (void)createFolderAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

- (NSArray *)loadNotebooks
{
    NSArray *directoryContents = [self getDirectoryContentForPath: [self notebooksRootDirectoryPath]];
    NSMutableArray *notebooksList = [[NSMutableArray alloc] init];
    for(int i = 0; i < directoryContents.count; i++)
    {
        Notebook *loadedNotebook = [[Notebook alloc] initWithName:[directoryContents objectAtIndex:i]];
        BOOL isHidden = [loadedNotebook.name hasPrefix:@"."];
        if(!isHidden)
        {
            [notebooksList addObject:loadedNotebook];
        }
    }
    return notebooksList;
}

- (NSMutableArray *)loadNotesForNotebookWithName:(NSString *)notebookName
{
    NSString *path = [self directoryPathForNotebookWithName:notebookName];
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

- (NSDirectoryEnumerator *)getEnumeratorForDir:(NSString *)dir
{
    return [[NSFileManager defaultManager] enumeratorAtPath:dir];
}

- (Note *)loadNoteWithPath:(NSString *)notePath andName:(NSString*) noteName
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

#pragma mark -
#pragma mark Note manager delegate

- (void)addNote:(Note *)newNote toNotebook:(Notebook *)notebook
{
    [self addNote:newNote toNotebookWithName:notebook.name];
}

- (void)addNote:(Note *)newNote toNotebookWithName:(NSString *)notebookName
{
    [self saveToDisk:newNote toNotebook:notebookName];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CREATED_EVENT object:nil userInfo:nil];
}

- (void)removeNote:(Note *)note fromNotebook:(Notebook *)notebook
{
    [self removeNote:note fromNotebookWithName:notebook.name];
}

- (void)removeNote:(Note *)note fromNotebookWithName:(NSString *)notebookName
{
    NSString *path = [self noteDirectoryPathForNote:note inNotebookWithName:notebookName];
    [self deleteItemAtPath:path];
}

- (void)renameNote:(Note *)note fromNotebook:(Notebook*) notebook oldName:(NSString*) oldName
{
    [self renameNote:note fromNotebookWithName:notebook.name oldName:oldName];
}

- (void)renameNote:(Note *)note fromNotebookWithName:(NSString *)notebookName oldName:(NSString *)oldName
{
    Note *dummyNote = [[Note alloc] init];
    dummyNote.name = oldName;
    
    NSString *oldPath = [self noteDirectoryPathForNote:dummyNote inNotebookWithName:notebookName];
    NSString *newPath = [[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:note.name];
    
    [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:nil];
}

- (NSArray *)noteListForNotebook:(Notebook *)notebook
{
    return [self noteListForNotebookWithName:notebook.name];
}

- (NSArray *)noteListForNotebookWithName:(NSString *)notebookName
{
    return [self loadNotesForNotebookWithName:notebookName];
}

#pragma mark -
#pragma mark Notebook manager delegate

- (void)addNotebook:(Notebook *)newNotebook
{
    NSString *notebookPath = [self directoryPathForNotebookWithName:newNotebook.name];
    [self createDirectoryAtPath:notebookPath];
}

- (void)addNotebookWithName:(NSString *)notebookName
{
    Notebook *notebook = [[Notebook alloc] initWithName:notebookName];
    [self addNotebook:notebook];
}

- (void)removeNotebook:(Notebook *)notebook
{
    [self removeNotebookWithName:notebook.name];
}

- (void)removeNotebookWithName:(NSString *)notebookName
{
    NSString *notebookPath = [self directoryPathForNotebookWithName:notebookName];
    [self deleteItemAtPath:notebookPath];
}

- (void)renameNotebook:(Notebook *)notebook newName:(NSString *)newName
{
    [self renameNotebookWithName:notebook.name newName:newName];
}

- (void)renameNotebookWithName:(NSString *)oldName newName:(NSString *)newName
{
    NSString *pathToNotebook = [self directoryPathForNotebookWithName:oldName];
    NSString *newPath = [[pathToNotebook stringByDeletingLastPathComponent] stringByAppendingPathComponent:newName];
    [[NSFileManager defaultManager] moveItemAtPath:pathToNotebook toPath:newPath error:nil];
}

-(NSArray *)notebookList
{
    return [self loadNotebooks];
}
@end
