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
@property UIViewController *controller;
@property NoteManager *manager;
@property DBUserClient *client;
@end

static NSString *const rederect = @"com.nemetschek.bg.Notes:/oauth2redirect";
static NSString *const clientID = GDRIVE_KEY;

@implementation DropboxNoteManager

-(id)initWithController:(UIViewController *)controller manager:(id)manager
{
    self = [super init];
    self.manager = manager;
    self.controller = controller;
    self.client = [DBClientsManager authorizedClient];
    return self;
}

//===============================
//========= DELEGATE ============
//===============================

//------ NOTEBOOKS ------
-(void)addNotebookWithName:(NSString *)notebookName
{
    NSString *notebookPath = [self getDirectoryPathForNotebookWithName:notebookName];
    [self createFolderAt:notebookPath];
}

-(void)addNotebook:(Notebook *)newNotebook
{
    [self addNotebookWithName:newNotebook.name];
}

-(void)removeNotebookWithName:(NSString *)notebookName
{
    NSString *notebookPath = [self getDirectoryPathForNotebookWithName:notebookName];
    [self deleteFolderAt:notebookPath];
}

-(void)removeNotebook:(Notebook *)notebook
{
    [self removeNotebookWithName:notebook.name];
}

-(void)renameNotebookWithName:(NSString *)oldName newName:(NSString *)newName
{
    [self renameNotebookInDropbox:oldName newName:newName];
}

-(void)renameNotebook:(Notebook *)notebook newName:(NSString *)newName
{
    [self renameNotebookWithName:notebook.name newName:newName];
}

//------ NOTES -------
-(void)addNote:(Note *)newNote toNotebookWithName:(NSString *)notebookName
{
    [self uploadNote:newNote inNotebookWithName:notebookName];
}

-(void)addNote:(Note *)newNote toNotebook:(Notebook *)notebook
{
    [self addNote:newNote toNotebookWithName:notebook.name];
}

-(void)removeNote:(Note *)note fromNotebookWithName:(NSString *)notebookName
{
    NSString *notebookPath = [self getNoteDirectoryPathForNote:note inNotebookWithName:notebookName];
    [self deleteFolderAt:notebookPath];
}

-(void)removeNote:(Note *)note fromNotebook:(Notebook *)notebook
{
    [self removeNote:note fromNotebookWithName:notebook.name];
}

-(void)renameNote:(Note *)note fromNotebookWithName:(NSString *)notebookName oldName:(NSString *)oldName
{
    [self renameNoteInDropbox:note fromNotebookWithName:notebookName oldName:oldName];
}

-(void)renameNote:(Note *)note fromNotebook:(Notebook *)notebook oldName:(NSString *)oldName
{
    [self renameNoteInDropbox:note fromNotebookWithName:notebook.name oldName:oldName];
}

//===============================
//======== END DELEGATE =========
//===============================

//zdr vanka

-(void) createFolderAt:(NSString*)path
{
    [self.client.filesRoutes createFolder:path];
}

-(void) deleteFolderAt:(NSString*)path
{
    [self.client.filesRoutes delete_:path];
}

-(void) renameNotebookInDropbox:(NSString*)oldName newName:(NSString *)newName
{
    NSString *oldPath = [self getDirectoryPathForNotebookWithName:oldName];
    NSString *newPath = [self getDirectoryPathForNotebookWithName:newName];
    [self.client.filesRoutes dCopy:oldPath toPath:newPath];
    [self deleteFolderAt:oldPath];
}

-(void) renameNoteInDropbox:(Note*) note fromNotebookWithName:(NSString*) notebookName oldName:(NSString*)oldName
{
    NSString *oldPath = [self getNoteDirectoryPathForNote:note inNotebookWithName:notebookName];
    Note *oldNote = [[Note alloc] init];
    oldNote.name = oldName;
    NSString *newPath = [self getNoteDirectoryPathForNote:oldNote inNotebookWithName:notebookName];
    [self.client.filesRoutes dCopy:oldPath toPath:newPath];
    [self deleteFolderAt:oldPath];
}

-(NSString*) getNoteDirectoryPathForNote:(Note*)note inNotebookWithName:(NSString*) notebookName
{
    return [[self getDirectoryPathForNotebookWithName:notebookName]
            stringByAppendingPathComponent:note.name];
}

-(NSString*) getDirectoryPathForNotebookWithName: (NSString*) notebookName
{
    return [[NSString stringWithFormat:@"/Notebooks"]
            stringByAppendingPathComponent:notebookName];
}

-(void) synchFiles
{
    [self synchNotebookFolders];
}

-(void) synchNotebookFolders
{
    NSArray *notebookList = [self.manager getNotebookList];
    for (Notebook *notebook in notebookList)
    {
        [self synchNoteFoldersForNotebookWithName:notebook];
    }
}

-(void) synchNoteFoldersForNotebookWithName:(NSString*)notebookName
{
    NSArray *noteList = [self.manager getNoteListForNotebookWithName:notebookName];
    for (Note *note in noteList)
    {
        [self uploadNote:note inNotebookWithName:notebookName];
    }
}
//zdr vanka

-(void) uploadNote:(Note*)note inNotebookWithName:(NSString*) notebookName
{
    //---- CREATE FOLDER -----
    NSString *notePathInDropBox = [NSString stringWithFormat:@"/Notebooks/%@/%@", notebookName, note.name];
    [self createFolderAt:notePathInDropBox];
    
    //---- UPLOAD FILES -----
    NSArray *filesList = [self getDirectoryContentForPath:[self.manager getNoteDirectoryPathForNote:note inNotebookWithName:notebookName]];
    
    for (NSString *fileName in filesList) {
        NSString *noteFilesPath = [[self.manager getNoteDirectoryPathForNote:note inNotebookWithName:notebookName]
                                   stringByAppendingPathComponent:fileName];
        NSString *dropboxPath = [NSString stringWithFormat:@"%@/%@",notePathInDropBox,fileName];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:noteFilesPath];
        [self.client.filesRoutes uploadData:dropboxPath inputData:data];
    }
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

-(void) handleError: (DBFILESListFolderError *) routeError networkError:(DBRequestError *) networkError
{
    NSString *title = @"";
    NSString *message = @"";
    if (routeError) {
        title = @"Route-specific error";
        if ([routeError isPath]) {
            message = [NSString stringWithFormat:@"Invalid path: %@", routeError.path];
        }
    } else {
        title = @"Generic request error";
        if ([networkError isInternalServerError]) {
            DBRequestInternalServerError *internalServerError = [networkError asInternalServerError];
            message = [NSString stringWithFormat:@"%@", internalServerError];
        } else if ([networkError isBadInputError]) {
            DBRequestBadInputError *badInputError = [networkError asBadInputError];
            message = [NSString stringWithFormat:@"%@", badInputError];
        } else if ([networkError isAuthError]) {
            DBRequestAuthError *authError = [networkError asAuthError];
            message = [NSString stringWithFormat:@"%@", authError];
        } else if ([networkError isRateLimitError]) {
            DBRequestRateLimitError *rateLimitError = [networkError asRateLimitError];
            message = [NSString stringWithFormat:@"%@", rateLimitError];
        } else if ([networkError isHttpError]) {
            DBRequestHttpError *genericHttpError = [networkError asHttpError];
            message = [NSString stringWithFormat:@"%@", genericHttpError];
        } else if ([networkError isClientError]) {
            DBRequestClientError *genericLocalError = [networkError asClientError];
            message = [NSString stringWithFormat:@"%@", genericLocalError];
        }
    }
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:(UIAlertActionStyle)UIAlertActionStyleCancel
                                                      handler:nil]];
    [self.controller presentViewController:alertController animated:YES completion:nil];
}

@end
