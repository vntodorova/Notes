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
#import "LocalNoteManager.h"
#import "Notebook.h"
#import "Note.h"

@interface DropboxNoteManager()
@property UIViewController *controller;
@property LocalNoteManager *manager;
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

-(void)uploadFile
{
    [[self.client.filesRoutes listFolder:@"/Notebooks"] setResponseBlock:^(DBFILESListFolderResult * _Nullable result, DBFILESListFolderError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        if (result)
        {
            for (DBFILESMetadata *item in result.entries) {
                NSLog(@"Files in folder %@", item);
            }
        }
        else
        {
            [self handleError:routeError networkError:networkError];
        }
    }];
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
        [self synchNoteFoldersForNotebook:notebook];
    }
}

-(void) synchNoteFoldersForNotebook:(Notebook*)notebook
{
    NSArray *noteList = [self.manager getNoteListForNotebookWithName:notebook.name];
    for (Note *note in noteList)
    {
        [self synchFilesForNote:note inNotebook:notebook];
    }
}

-(void) synchFilesForNote:(Note*)note inNotebook:(Notebook*) notebook
{
    //---- CREATE FOLDER -----
    NSString *notePathInDropBox = [NSString stringWithFormat:@"/Notebooks/%@/%@", notebook.name, note.name];
    [self.client.filesRoutes createFolder:notePathInDropBox];
    
    //---- UPLOAD FILES -----
    NSArray *filesList = [self getDirectoryContentForPath:[self.manager getNoteDirectoryPathForNote:note inNotebookWithName:notebook.name]];
    
    for (NSString *fileName in filesList) {
        NSString *noteFilesPath = [[self.manager getNoteDirectoryPathForNote:note inNotebookWithName:notebook.name]
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
