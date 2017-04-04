//
//  BoldOperator.m
//  Notes
//
//  Created by VCS on 4/4/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "BoldOperator.h"

@implementation BoldOperator

-(void)formatText:(NSAttributedString *)text
{
    NSValue *value = [self.rangeList objectAtIndex:0];
    NSRange range;
    [value getValue:&range];
    NSLog(@"%lu",(unsigned long)range.length);
}

@end
