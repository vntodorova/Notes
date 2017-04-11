//
//  ThemeManager.m
//  Notes
//
//  Created by Nemetschek A-Team on 4/10/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "ThemeManager.h"
#import "Defines.h"

static ThemeManager *sharedInstance = nil;

@implementation ThemeManager

+ (ThemeManager *)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[ThemeManager alloc] init];
    }
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.styles = [[NSMutableDictionary alloc] init];
        self.themeNames = [[NSArray alloc] initWithObjects:@"Light", @"Dark", @"Wood", nil];
        [self loadLightTheme];
    }
    return self;
}

- (void)loadLightTheme
{
    [self.styles setObject:[UIImage imageNamed:@"light_theme_plus.png"] forKey:PLUS_IMAGE];
    [self.styles setObject:[UIImage imageNamed:@"light_theme_menu.png"] forKey:MENU_IMAGE];
    [self.styles setObject:[UIColor whiteColor] forKey:TABLEVIEW_BACKGROUND_COLOR];
}

- (void)loadDarkTheme
{
    [self.styles setObject:[UIImage imageNamed:@"dark_theme_plus.png"] forKey:PLUS_IMAGE];
    [self.styles setObject:[UIImage imageNamed:@"dark_theme_menu.png"] forKey:MENU_IMAGE];
    [self.styles setObject:[UIColor darkGrayColor] forKey:TABLEVIEW_BACKGROUND_COLOR];
    [self.styles setObject:[UIColor lightGrayColor] forKey:TABLEVIEW_CELL_COLOR];
}

@end
