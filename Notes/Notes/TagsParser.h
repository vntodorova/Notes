//
//  TagsParser.h
//  Notes
//
//  Created by VCS on 4/19/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagsParser : NSObject

- (NSArray *)getTagsFromText:(NSString *) tagsText;

- (NSString *) buildTextFromTags:(NSArray *)tagsList;

@end
