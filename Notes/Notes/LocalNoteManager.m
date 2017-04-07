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

@property NSMutableDictionary *notebookList;
@property NSMutableArray *notebookObjectList;
@end

@implementation LocalNoteManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.notebookList = [[NSMutableDictionary alloc] init];
        self.notebookObjectList = [[NSMutableArray alloc] init];
        [self loadSavedData];
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
    if(newNotebook && [self.notebookList objectForKey:newNotebook.name] != nil)
    {
        [self.notebookList setObject:[[NSMutableArray alloc] init] forKey:newNotebook.name];
        [self.notebookObjectList addObject:newNotebook];
    }
}

- (void)removeNotebook:(Notebook *)notebook
{
    [self.notebookList removeObjectForKey:notebook.name];
}

- (void)addNote:(Note *)newNote toNotebook:(Notebook *)notebook
{
    if(newNote && notebook)
    {
        NSMutableArray *array = [self.notebookList objectForKey:notebook.name];
        [array addObject:newNote];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CREATED_EVENT object:nil userInfo:nil];
        [self saveToDisk:newNote toNotebook:notebook];
    }
}

-(void) saveToDisk:(Note *)newNote toNotebook:(Notebook *)notebook
{
    
    NSString *fileInnerPath = [NSString stringWithFormat:@"%@/%@", notebook.name, newNote.name];
    NSError *error;

    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:fileInnerPath];
    
    BOOL isDir;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:fileInnerPath isDirectory:&isDir])
    {
        if([fm createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil])
        {
            NSLog(@"Directory Created");
        }
        else
        {
            NSLog(@"Directory Creation Failed");
            return;
        }
    }
    else
    {
        NSLog(@"Directory Already Exist");
    }
    
    NSString *tags = [self extractTags:newNote.tags];
    
    NSString *fileTagsPath = [NSString stringWithFormat:@"%@/tags.txt", filePath];
    [tags writeToFile:fileTagsPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NSString *fileBodyPath = [NSString stringWithFormat:@"%@/body.html", filePath];
    NSString *stringToWrite = newNote.body;
    [stringToWrite writeToFile:fileBodyPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

- (NSString*) extractTags:(NSArray*) tags
{
    NSMutableString *tagsContent = [[NSMutableString alloc] init];
    for (NSString *tag in tags) {
        [tagsContent appendString:tag];
    }
    return tagsContent;
}

- (void)removeNote:(Note *)note fromNotebook:(NSString *)notebookName
{
    if(note && notebookName)
    {
        NSMutableArray *array = [self.notebookList objectForKey:notebookName];
        [array removeObject:note];
    }
}

- (NSArray *)getNotebookList
{
    return self.notebookObjectList;
}

- (NSArray<Note *> *)getNoteListForNotebook:(Notebook *)notebook
{
    NSArray *array;
    if(notebook)
    {
        array = [self.notebookList objectForKey:notebook.name];
    }
    return array;
}

- (NSArray<Note *> *)getNoteListForNotebookWithName:(NSString *)notebookName
{
    NSArray *array;
    if(notebookName)
    {
        array = [self.notebookList objectForKey:notebookName];
    }
    return array;
}

#pragma mark PRIVATE
- (void)loadSavedData
{
    //TODO if empty notebook
    Notebook* notebook1 = [[Notebook alloc] initWithName:@"General"];
    
    Notebook* notebook2 = [[Notebook alloc] initWithName:@"Work"];
    
    Notebook* notebook3 = [[Notebook alloc] initWithName:@"Home"];
    
    [self.notebookObjectList addObject:notebook1];
    [self.notebookObjectList addObject:notebook2];
    [self.notebookObjectList addObject:notebook3];
    
    Note *note1 = [[Note alloc] init];
    note1.name = @"1st note";
    note1.dateCreated = @"12:34, 4.5.2016";
    
    Note *note2 = [[Note alloc] init];
    note2.name = @"2nd note";
    note2.dateCreated = @"12:35, 4.5.2016";
    
    Note *note3 = [[Note alloc] init];
    note3.name = @"3rd note";
    note3.dateCreated = @"12:35, 4.5.2016";
    
    [self.notebookList setObject: [[NSMutableArray alloc] init] forKey:notebook1.name];
    [self.notebookList setObject: [[NSMutableArray alloc] init] forKey:notebook2.name];
    [self.notebookList setObject: [[NSMutableArray alloc] init] forKey:notebook3.name];
    
    NSMutableArray *array = [self.notebookList objectForKey:notebook1.name];
    
    [array addObject:note1];
    [array addObject:note2];
    [array addObject:note3];
}

@end
