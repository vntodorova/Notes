//
//  TextEditorOperator.h
//  Notes
//
//  Created by VCS on 4/4/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextEditorOperator : NSObject
@property NSMutableArray *rangeList;

-(void) formatText:(NSAttributedString *) text;

-(void) addRange:(NSRange*) range;

@end
