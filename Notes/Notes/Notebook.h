//
//  Notebook.h
//  Notes
//
//  Created by Nemetschek A-Team on 4/4/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Note;
@interface Notebook : NSObject

@property NSString *name;
@property NSMutableArray<Note *> *notes;

@end
