//
//  TableViewDataModel.h
//  Notes
//
//  Created by Nemetschek A-Team on 4/6/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Notebook;
@class Note;
@class Reminder;

@interface TableViewDataModel : NSObject

@property Notebook *notebook;
@property Note *note;
@property Reminder *reminder;

@end
