//
//  Note.m
//  Notes
//
//  Created by VCS on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "Note.h"

@implementation Note

- (NSString *)description
{
    return [NSString stringWithFormat:@"Name: %@", self.name];
}

@end
