//
//  LocalNoteManager.m
//  Notes
//
//  Created by VCS on 4/6/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "LocalNoteManager.h"
#import "Defines.h"

@interface LocalNoteManager()

@property NSMutableDictionary<NSString*, NSMutableArray<Note*>*> *notebookList;
@property NSMutableArray<Notebook*> *notebookObjectList;
@property NSString *contentPath;
@end

@implementation LocalNoteManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.notebookList = [[NSMutableDictionary alloc] init];
        self.notebookObjectList = [[NSMutableArray alloc] init];
        self.contentPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                              stringByAppendingPathComponent: NOTE_NOTEBOOKS_FOLDER];
        [self loadNotebooks];
    }
    return self;
}

- (void)exchangeNoteAtIndex:(NSInteger)firstIndex withNoteAtIndex:(NSInteger)secondIndex fromNotebook:(NSString *)notebookName
{
    NSMutableArray *array = [self.notebookList objectForKey:notebookName];
    [array exchangeObjectAtIndex:firstIndex withObjectAtIndex:secondIndex];
    [self.notebookList setObject:array forKey:notebookName];
}

- (void)addNotebook:(Notebook *) newNotebook
{
    if(newNotebook == nil || [self.notebookList objectForKey:newNotebook.name] == nil)
    {
        return;
    }
    else
    {
        [self.notebookList setObject:[[NSMutableArray alloc] init] forKey:newNotebook.name];
        [self.notebookObjectList addObject:newNotebook];
    }
}

- (void)addNote:(Note *)newNote toNotebook:(Notebook *)notebook
{
    if(newNote == nil || notebook == nil)
    {
        return;
    }
    else
    {
        NSMutableArray *array = [self.notebookList objectForKey:notebook.name];
        [array addObject:newNote];
        [self saveToDisk:newNote toNotebook:notebook];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CREATED_EVENT object:nil userInfo:nil];
    }
}

- (void)removeNotebook:(Notebook *)notebook
{
    [self.notebookList removeObjectForKey:notebook.name];
    NSString *path = [self.contentPath stringByAppendingPathComponent:notebook.name];
    
    [self deleteItemAtPath:path];
    
}

- (void)removeNote:(Note *)note fromNotebook:(NSString *)notebookName
{
    if(note == nil || notebookName == nil)
    {
        return;
    }
    else
    {
        NSString *path = [[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                                stringByAppendingPathComponent:NOTE_NOTEBOOKS_FOLDER]
                               stringByAppendingPathComponent:notebookName]
                              stringByAppendingPathComponent:note.name];
        
        NSMutableArray *array = [self.notebookList objectForKey:notebookName];
        [array removeObject:note];
        
        [self deleteItemAtPath:path];
    }
}

- (NSArray *)getNotebookList
{
    return self.notebookObjectList;
}

-(void) deleteItemAtPath:(NSString*) path
{
    NSError *error;
    BOOL isSuccessful = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    
    if(!isSuccessful)
    {
        @throw [NSException exceptionWithName:@"FileNotFoundException"
                                       reason:error.description
                                     userInfo:nil];;
    }
}

- (NSArray<Note *> *)getNoteListForNotebook:(Notebook *)notebook
{
    NSArray *array = nil;
    if(notebook)
    {
        if(!notebook.isLoaded)
        {
            NSMutableArray *loaddedNotes = [self loadNotesForNotebook:notebook];
            [self.notebookList setObject:loaddedNotes forKey:notebook.name];
            notebook.isLoaded = YES;
        }
        array = [self.notebookList objectForKey:notebook.name];
    }
    return array;
}

- (NSArray<Note *> *)getNoteListForNotebookWithName:(NSString *)notebookName
{
    Notebook *notebook = [self getNotebookWithName:notebookName];
    NSArray *noteList = [self getNoteListForNotebook:notebook];
    return noteList;
}

- (Notebook*) getNotebookWithName:(NSString *) notebookName
{
    for (Notebook *currentNotebook in self.notebookObjectList) {
        if([currentNotebook.name isEqualToString:notebookName])
        {
            return currentNotebook;
        }
    }
    return nil;
}

#pragma mark PRIVATE
- (void) saveToDisk:(Note *)newNote toNotebook:(Notebook *)notebook
{
    NSString *fileRoot = [[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                            stringByAppendingPathComponent:NOTE_NOTEBOOKS_FOLDER]
                            stringByAppendingPathComponent:notebook.name]
                            stringByAppendingPathComponent:newNote.name];
    
    [self isValidDirectory:fileRoot];
    
    [self saveData:[self extractTags:newNote.tags]  toFile:[fileRoot stringByAppendingPathComponent:NOTE_TAGS_FILE]];
    [self saveData:newNote.body                     toFile:[fileRoot stringByAppendingPathComponent:NOTE_BODY_FILE]];
    [self saveData:newNote.dateCreated              toFile:[fileRoot stringByAppendingPathComponent:NOTE_DATE_FILE]];
}

-(void) saveData:(NSString*) fileContent toFile:(NSString*) path
{
    NSError *error;
    [fileContent writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

-(void) isValidDirectory:(NSString*) path
{
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:path isDirectory:nil])
    {
        return;
    }
    else
    {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSString*) extractTags:(NSArray*) tags
{
    NSMutableString *tagsContent = [[NSMutableString alloc] init];
    for (NSString *tag in tags)
    {
        [tagsContent appendString:[NSString stringWithFormat:@"%@ #", tag]];
    }
    return tagsContent;
}

//LOAD DATA
- (void) loadNotebooks
{
    NSArray *directoryContents = [self getDirectoryContentForPath:self.contentPath];
    
    for(int i = 0; i < directoryContents.count; i++)
    {
        Notebook *loadedNotebook = [[Notebook alloc] initWithName:[directoryContents objectAtIndex:i]];
        BOOL isHidden = [loadedNotebook.name hasPrefix:@"."];
        if(!isHidden)
        {
            [self.notebookObjectList addObject:loadedNotebook];
        }
    }
}

//trqbva da se loadvat pri request
- (NSMutableArray*) loadNotesForNotebook:(Notebook*) notebook
{
    NSString *path = [self.contentPath stringByAppendingPathComponent:notebook.name];
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

-(NSArray*) getDirectoryContentForPath:(NSString*) path
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

- (Note*)loadNoteWithPath:(NSString*) notePath andName:(NSString*) noteName
{
    Note *note = [[Note alloc] init];
    
    note.name = noteName;
    note.body = [self loadDataFromFilePath:[NSString stringWithFormat:@"%@/%@",notePath, NOTE_BODY_FILE]];
    note.dateCreated = [self loadDataFromFilePath:[NSString stringWithFormat:@"%@/%@",notePath, NOTE_DATE_FILE]];
    
    NSString *tags = [self loadDataFromFilePath:[NSString stringWithFormat:@"%@/%@",notePath, NOTE_TAGS_FILE]];
    note.tags = [tags componentsSeparatedByString:@" "];
    return note;
}

- (NSString*) loadNoteBodyFromPath:(NSString*) path
{
    return nil;
}

- (NSString*)loadDataFromFilePath:(NSString*) path
{
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    return fileContents;
}

@end