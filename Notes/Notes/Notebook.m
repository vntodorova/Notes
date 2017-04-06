//
//  Notebook.m
//  Notes
//
//  Created by Nemetschek A-Team on 4/4/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "Notebook.h"

@implementation Notebook

- (id)init
{
    self = [super init];
    if(self)
    {
        self.notes = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
