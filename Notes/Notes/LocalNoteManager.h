//
//  LocalNoteManager.h
//  Notes
//
//  Created by VCS on 4/6/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.h"

@interface LocalNoteManager : NSObject <NoteManagerDelegate, NotebookManagerDelegate>

- (instancetype)initWithResponseHandler:(NSObject<ResponseHandler>*)responseHandler;

@end
