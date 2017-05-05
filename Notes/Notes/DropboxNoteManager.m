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
    [[self.client.filesRoutes dCopy:oldPath toPath:newPath] setResponseBlock:^(DBFILESMetadata * _Nullable result, DBFILESRelocationError * _Nullable routeError, DBRequestError * _Nullable networkError) {
          [self deleteFolderAt:oldPath];
    }];
}

- (void)renameNoteInDropbox:(Note *)note fromNotebookWithName:(NSString *)notebookName oldName:(NSString *)oldName
{
    NSString *oldPath = [self getNoteDirectoryPathForNote:note inNotebookWithName:notebookName];
    Note *oldNote = [[Note alloc] init];
    oldNote.name = oldName;
    NSString *newPath = [self getNoteDirectoryPathForNote:oldNote inNotebookWithName:notebookName];
    [[self.client.filesRoutes dCopy:oldPath toPath:newPath] setResponseBlock:^(DBFILESMetadata * _Nullable result, DBFILESRelocationError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        [self deleteFolderAt:oldPath];
    }];
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
            [self handleUploadResult:result note:note notebookWithName:notebookName];
        }];
    }
}

- (void)handleUploadResult:(DBFILESMetadata*)result note:(Note*)note notebookWithName:(NSString*)notebookName
{
    NSDate *date = [[DBFILESMetadataSerializer serialize:result] objectForKey:@"server_modified"];
    NSDate *newDate = [[DateTimeManager sharedInstance] dateFromString:date.description withFormat:SYSTEM_DATE_FORMAT];
    NSString *pathToFileBody = [[self.manager getNoteDirectoryPathForNote:note inNotebookWithName:notebookName] stringByAppendingPathComponent:NOTE_BODY_FILE];
    NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys: newDate, NSFileModificationDate, nil];
    [[NSFileManager defaultManager] setAttributes: attr ofItemAtPath: pathToFileBody error:nil];
}

- (void)downloadNote:(Note*)note fromNotebookWithName:(NSString*)notebookName
{
    NSString *source = [self getNoteDirectoryPathForNote:note inNotebookWithName:notebookName];
    [[self.client.filesRoutes listFolder:source] setResponseBlock:^(DBFILESListFolderResult * _Nullable result, DBFILESListFolderError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        NSString *destination = [self.manager getNoteDirectoryPathForNote:note inNotebookWithName:notebookName];
        [self mirrorAllFilesAtFromResult:result toDestination:destination];
    }];
}

- (void)mirrorAllFilesAtFromResult:(DBFILESListFolderResult*)result toDestination:(NSString*)destination
{
    [self createDownloadFolderAt:destination];
    for(DBFILESMetadata *data in result.entries.copy)
    {
        NSString *destinationPathToFile = [destination stringByAppendingPathComponent:data.name];
        NSURL *destinationURL = [NSURL fileURLWithPath:destinationPathToFile];
        [self.client.filesRoutes downloadUrl:data.pathDisplay overwrite:YES destination:destinationURL];
    }
}

- (void)createDownloadFolderAt:(NSString*)destination
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:destination isDirectory:nil] == NO)
    {
        [fileManager createDirectoryAtPath:destination withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSArray *)getDirectoryContentForPath:(NSString *)path
{
    NSError *error;
    NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    
    if(error)
    {
        @throw [NSException exceptionWithName:DIRECTORY_NOT_FOUND_EXCEPTION
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

- (void)copyNote:(Note *)note fromNotebookWithName:(NSString *)source toNotebookWithName:(NSString *)destination
{
    NSString *sourcePath = [self getNoteDirectoryPathForNote:note inNotebookWithName:source];
    NSString *destinationPath = [self getNoteDirectoryPathForNote:note inNotebookWithName:destination];
    [self.client.filesRoutes dCopy:sourcePath toPath:destinationPath];
}

- (void)copyNote:(Note *)note fromNotebook:(Notebook *)source toNotebook:(Notebook *)destination
{
    [self copyNote:note fromNotebookWithName:source.name toNotebookWithName:destination.name];
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
             if([data.name containsString:NOTE_BODY_FILE])
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
    note.dateModified = [[DateTimeManager sharedInstance] dateFromString:date.description withFormat:SYSTEM_DATE_FORMAT].description;
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

- (void)requestNotebookList
{
    [[self.client.filesRoutes listFolder:@"/Notebooks"]
     setResponseBlock:^(DBFILESListFolderResult *response, DBFILESListFolderError *routeError, DBRequestError *networkError)
     {
         NSMutableArray *notebookList = [[NSMutableArray alloc] init];
         for (DBFILESMetadata *data in response.entries)
         {
             Notebook *notebook = [[Notebook alloc] initWithName:data.name];
             [notebookList addObject:notebook];
             [self.manager handleResponseWithNotebookList:notebookList fromManager:self];
         }
     }];
}

@end
