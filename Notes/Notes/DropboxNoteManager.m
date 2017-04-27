//
//  GoogleNoteManager.m
//  Notes
//
//  Created by VCS on 4/21/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "DropboxNoteManager.h"
#import "Defines.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import "NoteManager.h"
#import "Notebook.h"
#import "Note.h"

@interface DropboxNoteManager()
@property NoteManager *manager;
@property DBUserClient *client;
@end

@implementation DropboxNoteManager

- (id)initWithManager:(id)manager
{
    self = [super init];
    self.manager = manager;
    self.client = [DBClientsManager authorizedClient];
    return self;
}

- (void)sendRequestForContentsInPath:(NSString *)path
{
    NSMutableArray *notebookList = [[NSMutableArray alloc] init];
    [[self.client.filesRoutes listFolder:@"/Notebooks"]
     setResponseBlock:^(DBFILESListFolderResult *response, DBFILESListFolderError *routeError, DBRequestError *networkError)
     {
         if (response)
         {
             for (DBFILESMetadata *data in response.entries)
             {
                 Notebook *notebook = [[Notebook alloc] initWithName:data.name];
                 [notebookList addObject:notebook];
             }
         } else {
             NSLog(@"%@\n%@\n", routeError, networkError);
         }
     }];
}

- (void)createFolderAt:(NSString *)path
{
    [self.client.filesRoutes createFolder:path];
}

- (void)deleteFolderAt:(NSString *)path
{
    [self.client.filesRoutes delete_:path];
}

- (void)renameNotebookInDropbox:(NSString *)oldName newName:(NSString *)newName
{
    NSString *oldPath = [self directoryPathForNotebookWithName:oldName];
    NSString *newPath = [self directoryPathForNotebookWithName:newName];
    [self.client.filesRoutes dCopy:oldPath toPath:newPath];
    [self deleteFolderAt:oldPath];
}

- (void)renameNoteInDropbox:(Note *)note fromNotebookWithName:(NSString *)notebookName oldName:(NSString *)oldName
{
    NSString *oldPath = [self noteDirectoryPathForNote:note inNotebookWithName:notebookName];
    Note *oldNote = [[Note alloc] init];
    oldNote.name = oldName;
    NSString *newPath = [self noteDirectoryPathForNote:oldNote inNotebookWithName:notebookName];
    [self.client.filesRoutes dCopy:oldPath toPath:newPath];
    [self deleteFolderAt:oldPath];
}

- (NSString *)noteDirectoryPathForNote:(Note *)note inNotebookWithName:(NSString *)notebookName
{
    return [[self directoryPathForNotebookWithName:notebookName]
            stringByAppendingPathComponent:note.name];
}

- (NSString *)directoryPathForNotebookWithName:(NSString *)notebookName
{
    return [@"/Notebooks" stringByAppendingPathComponent:notebookName];
}

- (void)syncFiles
{
    [self syncNotebookFolders];
}

- (void)syncNotebookFolders
{
    NSArray *notebookList = [self.manager notebookList];
    for (Notebook *notebook in notebookList)
    {
        [self syncNoteFoldersForNotebookWithName:notebook.name];
    }
}

- (void)syncNoteFoldersForNotebookWithName:(NSString *)notebookName
{
    NSArray *noteList = [self.manager noteListForNotebookWithName:notebookName];
    for (Note *note in noteList)
    {
        [self uploadNote:note inNotebookWithName:notebookName];
    }
}

- (void)uploadNote:(Note*)note inNotebookWithName:(NSString *)notebookName
{
    NSString *notePathInDropBox = [NSString stringWithFormat:@"/Notebooks/%@/%@", notebookName, note.name];
    [self createFolderAt:notePathInDropBox];
    
    NSArray *filesList = [self directoryContentForPath:[self.manager noteDirectoryPathForNote:note inNotebookWithName:notebookName]];
    
    for (NSString *fileName in filesList) {
        NSString *noteFilesPath = [[self.manager noteDirectoryPathForNote:note inNotebookWithName:notebookName]
                                   stringByAppendingPathComponent:fileName];
        NSString *dropboxPath = [NSString stringWithFormat:@"%@/%@",notePathInDropBox,fileName];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:noteFilesPath];
        [self.client.filesRoutes uploadData:dropboxPath inputData:data];
    }
}

- (NSArray *)directoryContentForPath:(NSString *)path
{
    NSError *error;
    NSArray *content = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:path error:&error];
    
    if(error)
    {
        @throw [NSException exceptionWithName:@"DirectoryNotFound"
                                       reason:error.description
                                     userInfo:nil];
    }
    return content;
}

#pragma mark -
#pragma mark Note manager delegates

- (void)addNote:(Note *)newNote toNotebookWithName:(NSString *)notebookName
{
    [self uploadNote:newNote inNotebookWithName:notebookName];
}

- (void)addNote:(Note *)newNote toNotebook:(Notebook *)notebook
{
    [self addNote:newNote toNotebookWithName:notebook.name];
}

- (void)removeNote:(Note *)note fromNotebookWithName:(NSString *)notebookName
{
    [self deleteFolderAt:[self noteDirectoryPathForNote:note inNotebookWithName:notebookName]];
}

- (void)removeNote:(Note *)note fromNotebook:(Notebook *)notebook
{
    [self removeNote:note fromNotebookWithName:notebook.name];
}

- (void)renameNote:(Note *)note fromNotebookWithName:(NSString *)notebookName oldName:(NSString *)oldName
{
    [self renameNoteInDropbox:note fromNotebookWithName:notebookName oldName:oldName];
}

- (void)renameNote:(Note *)note fromNotebook:(Notebook *)notebook oldName:(NSString *)oldName
{
    [self renameNoteInDropbox:note fromNotebookWithName:notebook.name oldName:oldName];
}

- (NSArray *)noteListForNotebook:(Notebook *)notebook
{
    return nil;
}

- (NSArray *)noteListForNotebookWithName:(NSString *)notebookName
{
    return nil;
}

#pragma mark -
#pragma mark Notebook manager delegates

- (void)addNotebookWithName:(NSString *)notebookName
{
    [self createFolderAt:[self directoryPathForNotebookWithName:notebookName]];
}

- (void)addNotebook:(Notebook *)newNotebook
{
    [self addNotebookWithName:newNotebook.name];
}

- (void)removeNotebookWithName:(NSString *)notebookName
{
    [self deleteFolderAt:[self directoryPathForNotebookWithName:notebookName]];
}

- (void)removeNotebook:(Notebook *)notebook
{
    [self removeNotebookWithName:notebook.name];
}

- (void)renameNotebookWithName:(NSString *)oldName newName:(NSString *)newName
{
    [self renameNotebookInDropbox:oldName newName:newName];
}

- (void)renameNotebook:(Notebook *)notebook newName:(NSString *)newName
{
    [self renameNotebookWithName:notebook.name newName:newName];
}

- (NSArray *)notebookList
{
    NSMutableArray *notebookList = [[NSMutableArray alloc] init];
    [[self.client.filesRoutes listFolder:@"/Notebooks"]
     setResponseBlock:^(DBFILESListFolderResult *response, DBFILESListFolderError *routeError, DBRequestError *networkError)
     {
         if (response)
         {
             for (DBFILESMetadata *data in response.entries)
             {
                 Notebook *notebook = [[Notebook alloc] initWithName:data.name];
                 [notebookList addObject:notebook];
             }
         } else {
             NSLog(@"%@\n%@\n", routeError, networkError);
         }
     }];
    return notebookList;
}

@end
