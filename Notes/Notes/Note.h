//
//  Note.h
//  Notes
//
//  Created by VCS on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Note : NSObject

@property NSString *name;
@property NSArray  *tags;
@property NSString *body;
@property NSString *dateModified;
@property NSString *triggerDate;

@end
