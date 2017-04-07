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
    }
}

- (void)removeNote:(Note *)note fromNotebook:(Notebook *)notebook
{
    if(note && notebook)
    {
        NSMutableArray *array = [self.notebookList objectForKey:notebook];
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
