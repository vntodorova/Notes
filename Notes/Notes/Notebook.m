//
//  Notebook.m
//  Notes
//
//  Created by Nemetschek A-Team on 4/4/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "Notebook.h"

@implementation Notebook

-(instancetype)initWithName:(NSString*) name
{
    self = [super init];
    self->_name = name;
    self.isLoaded = false;
    return self;
}

@end
