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
@property NoteManager *noteManager;
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
    self.noteManager = manager;
    self.currentNoteList = [[NSMutableArray alloc] init];
    self.client = [DBClientsManager authorizedClient];
    return self;
}

- (void)sendRequestForContentsInPath:(NSString*) path
{
    NSMutableArray *notebookList = [[NSMutableArray alloc] init];
    [[self.client.filesRoutes listFolder:DROPBOX_ROOT_DIRECTORY]
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

- (NSString *)getNoteDirectoryPathForNote:(Note *)note inNotebookWithName:(NSString *)notebookName
{
    return [[self getDirectoryPathForNotebookWithName:notebookName]
            stringByAppendingPathComponent:note.name];
}

- (NSString *)getDirectoryPathForNotebookWithName:(NSString *)notebookName
{
    return [DROPBOX_ROOT_DIRECTORY stringByAppendingPathComponent:notebookName];
}

- (void)mergeModificationDateOf:(DBFILESMetadata*)result andFileAt:(NSString*)path
{
    NSDate *date = [[DBFILESMetadataSerializer serialize:result] objectForKey:DROPBOX_SERVER_MODIFED_KEY];
    NSDate *newDate = [[DateTimeManager sharedInstance] dateFromString:date.description withFormat:SYSTEM_DATE_FORMAT];
    NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys: newDate, NSFileModificationDate, nil];
    [[NSFileManager defaultManager] setAttributes: attr ofItemAtPath: path error:nil];
}

- (void)downloadNote:(Note*)note fromNotebookWithName:(NSString*)notebookName
{
    NSString *source = [self getNoteDirectoryPathForNote:note inNotebookWithName:notebookName];
    [[self.client.filesRoutes listFolder:source] setResponseBlock:^(DBFILESListFolderResult * _Nullable result, DBFILESListFolderError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        NSString *destination = [self.noteManager getNoteDirectoryPathForNote:note inNotebookWithName:notebookName];
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
        [[self.client.filesRoutes downloadUrl:data.pathDisplay overwrite:YES destination:destinationURL] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESDownloadError * _Nullable routeError, DBRequestError * _Nullable networkError, NSURL * _Nonnull destination) {
            [self mergeModificationDateOf:result andFileAt:destinationPathToFile];
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTE_DOWNLOADED object:nil];
            NSLog(@"DropboxManager : file downloaded at path : %@",data.pathDisplay);
        }];
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

- (Note *)parseNoteFromData:(DBFILESMetadata *)metadata
{
    Note *note = [[Note alloc] init];
    note.name = [[metadata.pathDisplay stringByDeletingLastPathComponent] lastPathComponent];
    NSString* date = [[DBFILESMetadataSerializer serialize:metadata] objectForKey:DROPBOX_SERVER_MODIFED_KEY];
    note.dateModified = [[DateTimeManager sharedInstance] dateFromString:date.description withFormat:SYSTEM_DATE_FORMAT].description;
    return note;
}

#pragma mark -
#pragma mark Note manager delegates

- (void)addNote:(Note *)newNote toNotebook:(Notebook *)notebook
{
    [self addNote:newNote toNotebookWithName:notebook.name];
}

- (void)addNote:(Note *)newNote toNotebookWithName:(NSString *)notebookName
{
    NSString *notePathInDropBox = [self getNoteDirectoryPathForNote:newNote inNotebookWithName:notebookName];
    [self createFolderAt:notePathInDropBox];
    
    NSArray *filesList = [self getDirectoryContentForPath:[self.noteManager getNoteDirectoryPathForNote:newNote inNotebookWithName:notebookName]];
    
    for (NSString *fileName in filesList) {
        NSString *localNoteFilesPath = [[self.noteManager getNoteDirectoryPathForNote:newNote inNotebookWithName:notebookName]
                                        stringByAppendingPathComponent:fileName];
        
        NSString *dropboxNoteFilesPath = [notePathInDropBox stringByAppendingPathComponent:fileName];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:localNoteFilesPath];
        
        [[self.client.filesRoutes uploadData:dropboxNoteFilesPath inputData:data] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESUploadError * _Nullable routeError, DBRequestError * _Nullable networkError) {
            NSString *pathToFileBody = [[self.noteManager getNoteDirectoryPathForNote:newNote inNotebookWithName:notebookName] stringByAppendingPathComponent:NOTE_BODY_FILE];
            [self mergeModificationDateOf:result andFileAt:pathToFileBody];
            NSLog(@"DropboxManager : uploaded note %@ to notebook %@",newNote,notebookName);
        }];
    }
}

- (void)removeNote:(Note *)note fromNotebook:(Notebook *)notebook
{
    [self removeNote:note fromNotebookWithName:notebook.name];
}

- (void)removeNote:(Note *)note fromNotebookWithName:(NSString *)notebookName
{
    NSString *notebookPath = [self getNoteDirectoryPathForNote:note inNotebookWithName:notebookName];
    [self deleteFolderAt:notebookPath];
}

- (void)renameNote:(Note *)note fromNotebook:(Notebook *)notebook oldName:(NSString *)oldName
{
    [self renameNote:note fromNotebookWithName:notebook.name oldName:oldName];
}

- (void)renameNote:(Note *)note fromNotebookWithName:(NSString *)notebookName oldName:(NSString *)oldName
{
    NSString *oldPath = [self getNoteDirectoryPathForNote:note inNotebookWithName:notebookName];
    Note *oldNote = [[Note alloc] init];
    oldNote.name = oldName;
    NSString *newPath = [self getNoteDirectoryPathForNote:oldNote inNotebookWithName:notebookName];
    [[self.client.filesRoutes dCopy:oldPath toPath:newPath] setResponseBlock:^(DBFILESMetadata * _Nullable result, DBFILESRelocationError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        [self deleteFolderAt:oldPath];
    }];
}

- (void)copyNote:(Note *)note fromNotebook:(Notebook *)source toNotebook:(Notebook *)destination
{
    [self copyNote:note fromNotebookWithName:source.name toNotebookWithName:destination.name];
}

- (void)copyNote:(Note *)note fromNotebookWithName:(NSString *)source toNotebookWithName:(NSString *)destination
{
    NSString *sourcePath = [self getNoteDirectoryPathForNote:note inNotebookWithName:source];
    NSString *destinationPath = [self getNoteDirectoryPathForNote:note inNotebookWithName:destination];
    [self.client.filesRoutes dCopy:sourcePath toPath:destinationPath];
}

- (void)requestNoteListForNotebook:(Notebook *)notebook
{
    [self requestNoteListForNotebookWithName:notebook.name];
}

- (void)requestNoteListForNotebookWithName:(NSString *)notebookName
{
    NSLog(@"DropboxManager : requested note list for : %@",notebookName);
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

- (void)addNotebook:(Notebook *)newNotebook
{
    [self addNotebookWithName:newNotebook.name];
}

- (void)addNotebookWithName:(NSString *)notebookName
{
    NSString *notebookPath = [self getDirectoryPathForNotebookWithName:notebookName];
    [self createFolderAt:notebookPath];
}

- (void)removeNotebook:(Notebook *)notebook
{
    [self removeNotebookWithName:notebook.name];
}

- (void)removeNotebookWithName:(NSString *)notebookName
{
    NSString *notebookPath = [self getDirectoryPathForNotebookWithName:notebookName];
    [self deleteFolderAt:notebookPath];
}

- (void)renameNotebook:(Notebook *)notebook newName:(NSString *)newName
{
    [self renameNotebookWithName:notebook.name newName:newName];
}

- (void)renameNotebookWithName:(NSString *)oldName newName:(NSString *)newName
{
    NSString *oldPath = [self getDirectoryPathForNotebookWithName:oldName];
    NSString *newPath = [self getDirectoryPathForNotebookWithName:newName];
    [[self.client.filesRoutes dCopy:oldPath toPath:newPath] setResponseBlock:^(DBFILESMetadata * _Nullable result, DBFILESRelocationError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        [self deleteFolderAt:oldPath];
    }];
}

- (void)requestNotebookList
{
    NSLog(@"DropboxManager : requested notebook list");
    [[self.client.filesRoutes listFolder:DROPBOX_ROOT_DIRECTORY]
     setResponseBlock:^(DBFILESListFolderResult *response, DBFILESListFolderError *routeError, DBRequestError *networkError)
     {
         NSMutableArray *notebookList = [[NSMutableArray alloc] init];
         for (DBFILESMetadata *data in response.entries)
         {
             Notebook *notebook = [[Notebook alloc] initWithName:data.name];
             [notebookList addObject:notebook];
         }
         [self.noteManager handleResponseWithNotebookList:notebookList fromManager:self];
     }];
}

@end
