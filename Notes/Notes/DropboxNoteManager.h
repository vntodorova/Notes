//
//  DropboxNoteManager.h
//  Notes
//
//  Created by VCS on 4/25/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LocalNoteManager.h"

@interface DropboxNoteManager : NSObject<UIPopoverPresentationControllerDelegate>

-initWithController:(UIViewController*) controller manager:(LocalNoteManager *) manager;

-(void) synchFiles;

@end

