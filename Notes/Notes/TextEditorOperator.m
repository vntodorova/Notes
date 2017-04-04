//
//  TextEditorOperator.m
//  Notes
//
//  Created by VCS on 4/4/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "TextEditorOperator.h"

@implementation TextEditorOperator

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.rangeList = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addRange:(NSRange *)range
{
    NSValue *value = [NSValue valueWithBytes:&range objCType:@encode(NSRange)];
    [self.rangeList addObject:value];
}

@end
