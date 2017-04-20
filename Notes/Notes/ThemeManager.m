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
        self.themeNames = [[NSArray alloc] initWithObjects:LIGHT_THEME, DARK_THEME, nil];
        self.currentTheme = [[NSUserDefaults standardUserDefaults] stringForKey:THEME_KEY];
        if(self.currentTheme == nil)
        {
            self.currentTheme = LIGHT_THEME;
        }
        [self setNewTheme:self.currentTheme];
    }
    return self;
}

- (void)loadLightTheme
{
    [self.styles setObject:[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1] forKey:TABLEVIEW_BACKGROUND_COLOR];
    [self.styles setObject:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1] forKey:TABLEVIEW_CELL_COLOR];
    [self.styles setObject:[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1] forKey:NAVIGATION_BAR_COLOR];
    [self.styles setObject:[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1] forKey:BACKGROUND_COLOR];
    [self.styles setObject:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0] forKey:TINT];
    [self.styles setObject:[NSNumber numberWithInt:UIBarStyleDefault] forKey:SEARCH_BAR];
    [self.styles setObject:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0] forKey:ALERTCONTROLLER_TINT];
}

- (void)loadDarkTheme
{
    [self.styles setObject:[UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1] forKey:TABLEVIEW_BACKGROUND_COLOR];
    [self.styles setObject:[UIColor colorWithRed:120.0/255.0 green:120.0/255.0 blue:120.0/255.0 alpha:1] forKey:TABLEVIEW_CELL_COLOR];
    [self.styles setObject:[UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1] forKey:NAVIGATION_BAR_COLOR];
    [self.styles setObject:[UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1] forKey:BACKGROUND_COLOR];
    [self.styles setObject:[UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1] forKey:TINT];
    [self.styles setObject:[NSNumber numberWithInt:UIBarStyleBlack] forKey:SEARCH_BAR];
    [self.styles setObject:[UIColor darkGrayColor] forKey:ALERTCONTROLLER_TINT];
}

- (void)reload
{
    if([self.currentTheme isEqualToString:LIGHT_THEME])
    {
        [self loadLightTheme];
    }
    else if([self.currentTheme isEqualToString:DARK_THEME])
    {
        [self loadDarkTheme];
    }
}

- (void)setNewTheme:(NSString *)newThemeName
{
    [[NSUserDefaults standardUserDefaults] setValue:newThemeName forKey:THEME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.currentTheme = newThemeName;
    [self reload];
}

@end
