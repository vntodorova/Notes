//
//  TagsParser.m
//  Notes
//
//  Created by VCS on 4/19/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "TagsParser.h"
#define TAG_SEPARATION_INDICATORS @"# "

@implementation TagsParser

- (NSArray *)getTagsFromText:(NSString *)tagsText
{
    NSArray *tagList;
    NSCharacterSet *setOfIndicators = [NSCharacterSet characterSetWithCharactersInString:TAG_SEPARATION_INDICATORS];
    tagList = [tagsText componentsSeparatedByCharactersInSet:setOfIndicators];
    NSMutableArray *clearTagList = [[NSMutableArray alloc] init];
    
    for(NSString *tag in tagList)
    {
        if([tag isEqualToString:@""])
        {
            continue;
        }
        [clearTagList addObject:tag];
    }
    return clearTagList;
}

- (NSString *)buildTextFromTags:(NSArray *)tagsList
{
    NSMutableString *tagsText = [[NSMutableString alloc] init];
    for(NSString *tag in tagsList)
    {
        [tagsText appendFormat:@"#%@ ",tag];
    }
    return tagsText;
}

@end
