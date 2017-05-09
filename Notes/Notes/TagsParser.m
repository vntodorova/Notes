//
//  TagsParser.m
//  Notes
//
//  Created by VCS on 4/19/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "TagsParser.h"

#define TAG_SEPARATION_INDICATORS @"# "
#define EMPTY_ELEMENT @""
#define TAG_BUILDING_FORMAT @"#%@ "

@implementation TagsParser

- (NSArray *)getTagsFromText:(NSString *)tagsText
{
    NSArray *tagList;
    NSCharacterSet *setOfIndicators = [NSCharacterSet characterSetWithCharactersInString:TAG_SEPARATION_INDICATORS];
    tagList = [tagsText componentsSeparatedByCharactersInSet:setOfIndicators];
    NSMutableArray *clearTagList = [[NSMutableArray alloc] init];
    
    for(NSString *tag in tagList)
    {
        if([tag isEqualToString:EMPTY_ELEMENT])
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
        [tagsText appendFormat:TAG_BUILDING_FORMAT,tag];
    }
    return tagsText;
}

@end
