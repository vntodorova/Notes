//
//  ThemeManager.h
//  Notes
//
//  Created by Nemetschek A-Team on 4/10/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ThemeManager : NSObject

+ (ThemeManager *)sharedInstance;

@property NSArray *themeNames;

@property NSMutableDictionary *styles;

@property NSString *currentTheme;

- (void)reload;

- (void)setNewTheme:(NSString *)newThemeName;

@end
