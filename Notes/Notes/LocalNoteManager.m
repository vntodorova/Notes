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

@property NSMutableDictionary<NSString*, NSMutableArray<Note*>*> *notebookDictionary;
@property NSMutableArray<Notebook*> *notebookList;

@end

@implementation LocalNoteManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.notebookDictionary = [[NSMutableDictionary alloc] init];
        [self createDirectoryAtPath: [self getNotebooksRootDirectoryPath]];
        self.notebookList = [[NSMutableArray alloc] init];
        [self loadNotebooks];
    }
    return self;
}

- (void)exchangeNoteAtIndex:(NSInteger)firstIndex withNoteAtIndex:(NSInteger)secondIndex fromNotebook:(NSString *)notebookName
{
    NSMutableArray *array = [self.notebookDictionary objectForKey:notebookName];
    [array exchangeObjectAtIndex:firstIndex withObjectAtIndex:secondIndex];
    [self.notebookDictionary setObject:array forKey:notebookName];
}

- (void)addNotebook:(Notebook *) newNotebook
{
    if(newNotebook == nil || [self.notebookDictionary objectForKey:newNotebook.name] != nil)
    {
        return;
    }

    [self.notebookDictionary setObject:[[NSMutableArray alloc] init] forKey:newNotebook.name];
    [self.notebookList addObject:newNotebook];
    NSString *notebookPath = [self getDirectoryPathForNotebookWithName:newNotebook.name];
    [self createDirectoryAtPath:notebookPath];
}

- (void)addNote:(Note *)newNote toNotebook:(Notebook *)notebook
{
    [self addNote:newNote toNotebookWithName:notebook.name];
}

- (void)addNote:(Note *)newNote toNotebookWithName:(NSString *)notebookName
{
    if(newNote == nil || notebookName == nil)
    {
        return;
    }
    
    NSMutableArray *noteList = [[NSMutableArray alloc]initWithArray:[self getNoteListForNotebookWithName:notebookName]];
    for(Note *note in noteList)
    {
        if([note.name isEqualToString:newNote.name])
        {
            [self removeNote:note fromNotebookWithName:notebookName];
            break;
        }
    }
    
    NSMutableArray *array = [self.notebookDictionary objectForKey:notebookName];
    
    [array addObject:newNote];
    [self saveToDisk:newNote toNotebook:notebookName];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CREATED_EVENT object:nil userInfo:nil];
}

- (void)removeNotebook:(Notebook *)notebook
{
    [self removeNotebookWithName:notebook.name];
}

- (void)removeNotebookWithName:(NSString *)notebookName
{
    [self removeNotebookFromAllLists:notebookName];
    NSString *notebookPath = [self getDirectoryPathForNotebookWithName:notebookName];
    [self deleteItemAtPath:notebookPath];
}

- (void) removeNotebookFromAllLists:(NSString *) notebookName
{
    [self.notebookDictionary removeObjectForKey:notebookName];
    [self.notebookList removeObject:[self getNotebookWithName:notebookName]];
}

- (void)removeNote:(Note *)note fromNotebook:(Notebook *)notebook
{
    [self removeNote:note fromNotebookWithName:notebook.name];
}

- (void)renameNotebookWithName:(NSString*) oldName newName:(NSString*) newName
{
    NSString *pathToNotebook = [self getDirectoryPathForNotebookWithName:oldName];
    NSString *newPath = [[pathToNotebook stringByDeletingLastPathComponent] stringByAppendingPathComponent:newName];
    [[NSFileManager defaultManager] moveItemAtPath:pathToNotebook toPath:newPath error:nil];
    
    [self.notebookDictionary setObject:[self.notebookDictionary objectForKey:oldName] forKey:newName];
    [self.notebookDictionary removeObjectForKey:oldName];
    
    [self getNotebookWithName:oldName].name = newName;
}

- (void)renameNotebook:(Notebook*) notebook newName:(NSString*) newName
{
    [self renameNotebookWithName:notebook.name newName:newName];
}

- (void)removeNote:(Note *)note fromNotebookWithName:(NSString *)notebookName
{
    if(note == nil || notebookName == nil)
    {
        return;
    }
    
    NSString *path = [self getNoteDirectoryPathForNote:note inNotebookWithName:notebookName];
    
    NSMutableArray *array = [self.notebookDictionary objectForKey:notebookName];
    [array removeObject:note];
    
    [self deleteItemAtPath:path];
}

- (NSArray *)getNotebookList
{
    return self.notebookList;
}

- (NSArray *) getNotebookNamesList
{
    return self.notebookDictionary.allKeys;
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

-(void) deleteItemAtPath:(NSString*) path
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

-(void) deleteTempFolder
{
    NSString *tempDirectory = [self getTempDirectoryPath];
    @try {
            [self deleteItemAtPath:tempDirectory];
    } @catch (NSException *exception) {
        
    }
}

-(void) createTempFolder
{
    NSString *tempDirectory = [self getTempDirectoryPath];
    [self createFoldarAtPath:tempDirectory];
}

-(NSString*) saveImage:(NSDictionary*) imageInfo withName:(NSString*)imageName forNote:(Note*) note inNotebookWithName:(NSString*) notebookName
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

-(NSString*) saveImage:(NSDictionary*) imageInfo withName:(NSString*)imageName forNote:(Note*) note inNotebook:(Notebook*) notebook;
{
    return [self saveImage:imageInfo withName:imageName forNote:note  inNotebookWithName:notebook.name];
}

-(NSString*) getCurrentTime
{
    DateTimeManager *timeManager = [[DateTimeManager alloc] init];
    return [timeManager getCurrentTime];
}

-(NSURL*) getBaseURLforNote:(Note*) note inNotebookWithName:(NSString*) notebookName
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

-(NSURL*) getBaseURLforNote:(Note*) note inNotebook:(Notebook*) notebook
{
    return [self getBaseURLforNote:note inNotebookWithName:notebook.name];;
}


#pragma mark PRIVATE
-(NSString*) getTempDirectoryPath
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
            stringByAppendingPathComponent:TEMP_FOLDER];
}

-(NSString*) getNotebooksRootDirectoryPath
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
            stringByAppendingPathComponent: NOTE_NOTEBOOKS_FOLDER];
}

-(NSString*) getDirectoryPathForNotebookWithName: (NSString*) notebookName
{
    return [[self getNotebooksRootDirectoryPath]
            stringByAppendingPathComponent:notebookName];
}

-(NSString*) getNoteDirectoryPathForNote:(Note*)note inNotebookWithName:(NSString*) notebookName
{
    return [[self getDirectoryPathForNotebookWithName:notebookName]
            stringByAppendingPathComponent:note.name];
}

- (void) saveToDisk:(Note *)newNote toNotebook:(NSString *)notebookName
{
    NSString *noteRoot = [self getNoteDirectoryPathForNote:newNote inNotebookWithName:notebookName];
    
    [self createDirectoryAtPath:noteRoot];
    
    [self saveData:[self buildTagsForSave:newNote.tags] toFile:[noteRoot stringByAppendingPathComponent:NOTE_TAGS_FILE]];
    [self saveData:newNote.body                         toFile:[noteRoot stringByAppendingPathComponent:NOTE_BODY_FILE]];
    [self saveData:newNote.dateCreated                  toFile:[noteRoot stringByAppendingPathComponent:NOTE_DATE_FILE]];
    [self saveData:newNote.triggerDate                  toFile:[noteRoot stringByAppendingPathComponent:NOTE_TRIGGER_DATE_FILE]];
    
    [self coppyFilesFromTempFolderTo:noteRoot];
}

-(void) coppyFilesFromTempFolderTo:(NSString*) destination
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tempFolderPath = [self getTempDirectoryPath];
    NSArray *directoryContents = [self getDirectoryContentForPath:tempFolderPath];
    
    for(NSString *imageName in directoryContents)
    {
        BOOL isHidden = [imageName hasPrefix:@"."];
        if(!isHidden)
        {
            NSString *imageSourcePath = [tempFolderPath stringByAppendingPathComponent:imageName];
            NSString *imageDestinationPath = [destination stringByAppendingPathComponent:imageName];
            
            [fileManager copyItemAtPath:imageSourcePath toPath:imageDestinationPath error:nil];
        }
    }
}

-(void) saveData:(NSString*) fileContent toFile:(NSString*) path
{
    NSError *error;
    [fileContent writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

-(void) createDirectoryAtPath:(NSString*) path
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

-(void) createFoldarAtPath:(NSString*) path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

- (NSString*) buildTagsForSave:(NSArray*) tags
{
    NSMutableString *tagsContent = [[NSMutableString alloc] init];
    for (NSString *tag in tags)
    {
        [tagsContent appendString:[NSString stringWithFormat:@"#%@", tag]];
    }
    return tagsContent;
}

//LOAD DATA
- (void) loadNotebooks
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

- (NSMutableArray*) loadNotesForNotebook:(Notebook*) notebook
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
    note.triggerDate = [self loadDataFromFilePath:[NSString stringWithFormat:@"%@/%@",notePath, NOTE_TRIGGER_DATE_FILE]];
    
    NSString *tags = [self loadDataFromFilePath:[NSString stringWithFormat:@"%@/%@",notePath, NOTE_TAGS_FILE]];
    note.tags = [self getTagsFromText:tags];
    return note;
}

- (NSString*)loadDataFromFilePath:(NSString*) path
{
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    return fileContents;
}

- (NSArray *)getTagsFromText:(NSString *) tagsText
{
    NSArray *tagList;
    NSCharacterSet *setOfIndicators = [NSCharacterSet characterSetWithCharactersInString:TAG_SEPARATION_INDICATORS];
    tagList = [tagsText componentsSeparatedByCharactersInSet:setOfIndicators];
    NSMutableArray *clearTagList = [[NSMutableArray alloc] init];
    
    for(NSString *tag in tagList)
    {
        if([tag isEqualToString:@""])
        {
            continue;
        }
        [clearTagList addObject:tag];
    }
    return clearTagList;
}
@end
