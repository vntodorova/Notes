//
//  DropboxNoteManager.h
//  Notes
//
//  Created by VCS on 4/25/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class NoteManager;

@interface DropboxNoteManager : NSObject<UIPopoverPresentationControllerDelegate, NotebookManagerDelegate, NoteManagerDelegate>

- (id)initWithController:(UIViewController*) controller manager:(NoteManager *) manager;

- (void)synchFiles;

@end

