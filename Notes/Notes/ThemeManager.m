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
        sharedInstance = [[self alloc] init];
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
    UIColor *mainColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1];
    UIColor *blueColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    [self.styles setObject:[UIImage imageNamed:@"light_theme_plus.png"] forKey:PLUS_IMAGE];
    [self.styles setObject:[UIImage imageNamed:@"light_theme_menu.png"] forKey:MENU_IMAGE];
    [self.styles setObject:mainColor forKey:TABLEVIEW_BACKGROUND_COLOR];
    [self.styles setObject:[UIColor whiteColor] forKey:TABLEVIEW_CELL_COLOR];
    [self.styles setObject:mainColor forKey:NAVIGATION_BAR_COLOR];
    [self.styles setObject:mainColor forKey:BACKGROUND_COLOR];
    [self.styles setObject:blueColor forKey:TEXT_COLOR];
    [self.styles setObject:[NSNumber numberWithFloat:1.0] forKey:TEXTFIELDS_ALPHA];
}

- (void)loadDarkTheme
{
    UIColor *mainColor = [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1];
    UIColor *textColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1];
    [self.styles setObject:[UIImage imageNamed:@"dark_theme_plus.png"] forKey:PLUS_IMAGE];
    [self.styles setObject:[UIImage imageNamed:@"dark_theme_menu.png"] forKey:MENU_IMAGE];
       [self.styles setObject:mainColor forKey:TABLEVIEW_BACKGROUND_COLOR];
    [self.styles setObject:[UIColor darkGrayColor] forKey:TABLEVIEW_CELL_COLOR];
    [self.styles setObject:mainColor forKey:NAVIGATION_BAR_COLOR];
    [self.styles setObject:mainColor forKey:BACKGROUND_COLOR];
    [self.styles setObject:textColor forKey:TEXT_COLOR];
    [self.styles setObject:[NSNumber numberWithFloat:0.4] forKey:TEXTFIELDS_ALPHA];
}

- (void)reload
{
    if([self.currentTheme isEqualToString:@"Light"])
    {
        [self loadLightTheme];
    } else if([self.currentTheme isEqualToString:@"Dark"])
    {
        [self loadDarkTheme];
    }
}

@end
