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
#import "Protocols.h"
#import "DateTimeManager.h"

@interface DropboxNoteManager()
@property NoteManager *manager;
@property DBUserClient *client;
@property id<ResponseHandler> handler;
@property int requestsSent;
@property int requestsRecived;
@property NSMutableArray *currentNoteList;
@end

@implementation DropboxNoteManager

- (id)initWithManager:(id)manager handler:(id)handler
{
    self = [super init];
    self.handler = handler;
    self.manager = manager;
    self.currentNoteList = [[NSMutableArray alloc] init];
    self.client = [DBClientsManager authorizedClient];
    return self;
}

- (void)sendRequestForContentsInPath:(NSString*) path
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
    NSString *oldPath = [self getDirectoryPathForNotebookWithName:oldName];
    NSString *newPath = [self getDirectoryPathForNotebookWithName:newName];
    [self.client.filesRoutes dCopy:oldPath toPath:newPath];
    [self deleteFolderAt:oldPath];
}

- (void)renameNoteInDropbox:(Note *)note fromNotebookWithName:(NSString *)notebookName oldName:(NSString *)oldName
{
    NSString *oldPath = [self getNoteDirectoryPathForNote:note inNotebookWithName:notebookName];
    Note *oldNote = [[Note alloc] init];
    oldNote.name = oldName;
    NSString *newPath = [self getNoteDirectoryPathForNote:oldNote inNotebookWithName:notebookName];
    [self.client.filesRoutes dCopy:oldPath toPath:newPath];
    [self deleteFolderAt:oldPath];
}

- (NSString *)getNoteDirectoryPathForNote:(Note *)note inNotebookWithName:(NSString *)notebookName
{
    return [[self getDirectoryPathForNotebookWithName:notebookName]
            stringByAppendingPathComponent:note.name];
}

- (NSString *)getDirectoryPathForNotebookWithName:(NSString *)notebookName
{
    return [@"/Notebooks" stringByAppendingPathComponent:notebookName];
}

- (void)syncFiles
{
    [self syncNotebookFolders];
}

- (void)syncNotebookFolders
{
    NSArray *notebookList = [self.manager getNotebookList];
    for (Notebook *notebook in notebookList)
    {
        [self syncNoteFoldersForNotebookWithName:notebook.name];
    }
}

- (void)syncNoteFoldersForNotebookWithName:(NSString *)notebookName
{
    NSArray *noteList = [self.manager getNoteListForNotebookWithName:notebookName];
    for (Note *note in noteList)
    {
        [self uploadNote:note inNotebookWithName:notebookName];
    }
}

- (void)uploadNote:(Note*)note inNotebookWithName:(NSString *)notebookName
{
    NSString *notePathInDropBox = [self getNoteDirectoryPathForNote:note inNotebookWithName:notebookName];
    [self createFolderAt:notePathInDropBox];
    
    NSArray *filesList = [self getDirectoryContentForPath:[self.manager getNoteDirectoryPathForNote:note inNotebookWithName:notebookName]];
    
    for (NSString *fileName in filesList) {
        NSString *noteFilesPath = [[self.manager getNoteDirectoryPathForNote:note inNotebookWithName:notebookName]
                                   stringByAppendingPathComponent:fileName];
        NSString *dropboxPath = [NSString stringWithFormat:@"%@/%@",notePathInDropBox,fileName];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:noteFilesPath];
        [[self.client.filesRoutes uploadData:dropboxPath inputData:data] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESUploadError * _Nullable routeError, DBRequestError * _Nullable networkError) {
            //2017-04-20 09:55:47 +0000
            //NSDate *newDate = [NSDate date];
            DateTimeManager *manager = [[DateTimeManager alloc] init];
            NSDate *date = [[DBFILESMetadataSerializer serialize:result] objectForKey:@"server_modified"];
            
            NSDate *newDate = [manager dateFromString:[manager stringFromDate:date]];
            NSString *pathToFileBody = [[self.manager getNoteDirectoryPathForNote:note inNotebookWithName:notebookName] stringByAppendingPathComponent:NOTE_BODY_FILE];
            NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys: newDate, NSFileModificationDate, NULL];
            [[NSFileManager defaultManager] setAttributes: attr ofItemAtPath: pathToFileBody error: NULL];
        }];
    }

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
    NSString *notebookPath = [self getNoteDirectoryPathForNote:note inNotebookWithName:notebookName];
    [self deleteFolderAt:notebookPath];
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

- (NSArray *)getNoteListForNotebook:(Notebook *)notebook
{
    return nil;
}

- (NSArray *)getNoteListForNotebookWithName:(NSString *)notebookName
{
    return nil;
}

- (void)requestNoteListForNotebook:(Notebook *)notebook
{
    [self requestNoteListForNotebookWithName:notebook.name];
}

- (void)requestNoteListForNotebookWithName:(NSString *)notebookName
{
    NSString *path = [self getDirectoryPathForNotebookWithName:notebookName];
    [[self.client.filesRoutes listFolder:path recursive:@YES includeMediaInfo:nil includeDeleted:nil includeHasExplicitSharedMembers:nil]
     setResponseBlock:^(DBFILESListFolderResult *response, DBFILESListFolderError *routeError, DBRequestError *networkError)
     {
         NSMutableArray *noteList = [[NSMutableArray alloc] init];
         for(DBFILESMetadata *data in response.entries)
         {
             if([data.name containsString:NOTE_DATE_FILE])
             {
                 [noteList addObject:[self parseNoteFromData:data]];
             }
         }
         [self.handler handleResponseWithNoteList:noteList fromNotebookWithName:notebookName fromManager:self];
     }];
}

#pragma mark -
#pragma mark Notebook manager delegates

- (Note*)parseNoteFromData:(DBFILESMetadata*) metadata
{
    Note *note = [[Note alloc] init];
    note.name = [[metadata.pathDisplay stringByDeletingLastPathComponent] lastPathComponent];
    NSString* date = [[DBFILESMetadataSerializer serialize:metadata] objectForKey:@"server_modified"];
    note.dateModified = date;
    return note;
}

- (void)addNotebookWithName:(NSString *)notebookName
{
    NSString *notebookPath = [self getDirectoryPathForNotebookWithName:notebookName];
    [self createFolderAt:notebookPath];
}

- (void)addNotebook:(Notebook *)newNotebook
{
    [self addNotebookWithName:newNotebook.name];
}

- (void)removeNotebookWithName:(NSString *)notebookName
{
    NSString *notebookPath = [self getDirectoryPathForNotebookWithName:notebookName];
    [self deleteFolderAt:notebookPath];
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

- (NSArray *)getNotebookList
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
                 notebook.notesCount = [self getNoteListForNotebook:notebook].count;
                 [notebookList addObject:notebook];
                 //NSLog(@"%@", data);
             }
         }
         else
         {
             NSLog(@"%@\n%@\n", routeError, networkError);
         }
     }];
    return notebookList;
}

- (void)requestContentsOfNote:(NSMutableArray *)noteList inNotebook:(NSString *)notebookName;
{
    if(noteList.count == 0)
    {
        //[self.handler handleResponseWithNoteList:self.currentNoteList fromNotebookWithName:notebookName fromManager:self];
        return;
    }
    [self.currentNoteList addObject:[noteList objectAtIndex:0]];
    Note *note = [noteList objectAtIndex:0];
    [noteList removeObjectAtIndex:0];
    
    NSString *path = [[self getNoteDirectoryPathForNote:note inNotebookWithName:notebookName] stringByAppendingPathComponent:NOTE_DATE_FILE];
    [[self.client.filesRoutes downloadData:path] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESDownloadError * _Nullable routeError, DBRequestError * _Nullable networkError, NSData * _Nullable fileData)
    {
        NSString *date = [[NSString alloc]initWithData:fileData encoding:NSUTF8StringEncoding];
        note.dateModified = date;
        [self requestContentsOfNote:noteList inNotebook:notebookName];
    }];
}

- (NSArray *)getContentsOfNote:(Note *)note inNotebook:(Notebook *)notebook
{
    return nil;
}

- (void)requestNotebookList
{
    
}

@end
