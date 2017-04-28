//
//  Notebook.h
//  Notes
//
//  Created by Nemetschek A-Team on 4/4/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Notebook : NSObject

-(instancetype)initWithName:(NSString*) name;

@property (nonatomic, strong) NSString *name;

@property NSInteger notesCount;

@property BOOL isLoaded;

@end
