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
        self.themeNames = [[NSArray alloc] initWithObjects:@"Light", @"Dark", nil];
        self.currentTheme = [[NSUserDefaults standardUserDefaults] stringForKey:@"Theme"];
        if(self.currentTheme == nil)
        {
            self.currentTheme = @"Light";
            [self setNewTheme:self.currentTheme];
        }
        else
        {
            [self reload];
        }
    }
    return self;
}

- (void)loadLightTheme
{
    UIColor *mainColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1];
    UIColor *textColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    [searchBar setBarStyle:UIBarStyleDefault];
    [self.styles setObject:mainColor forKey:TABLEVIEW_BACKGROUND_COLOR];
    [self.styles setObject:[UIColor whiteColor] forKey:TABLEVIEW_CELL_COLOR];
    [self.styles setObject:mainColor forKey:NAVIGATION_BAR_COLOR];
    [self.styles setObject:mainColor forKey:BACKGROUND_COLOR];
    [self.styles setObject:textColor forKey:TEXT_COLOR];
    [self.styles setObject:[NSNumber numberWithFloat:1.0] forKey:TEXTFIELDS_ALPHA];
    [self.styles setObject:searchBar forKey:SEARCH_BAR];
}

- (void)loadDarkTheme
{
    UIColor *mainColor = [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1];
    UIColor *textColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1];
    UIColor *tableViewCellColor = [UIColor colorWithRed:120.0/255.0 green:120.0/255.0 blue:120.0/255.0 alpha:1];
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    [searchBar setBarStyle:UIBarStyleBlack];
       [self.styles setObject:mainColor forKey:TABLEVIEW_BACKGROUND_COLOR];
    [self.styles setObject:tableViewCellColor forKey:TABLEVIEW_CELL_COLOR];
    [self.styles setObject:mainColor forKey:NAVIGATION_BAR_COLOR];
    [self.styles setObject:mainColor forKey:BACKGROUND_COLOR];
    [self.styles setObject:textColor forKey:TEXT_COLOR];
    [self.styles setObject:[NSNumber numberWithFloat:0.4] forKey:TEXTFIELDS_ALPHA];
    [self.styles setObject:searchBar forKey:SEARCH_BAR];
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

- (void)setNewTheme:(NSString *)newThemeName
{
    [[NSUserDefaults standardUserDefaults] setValue:newThemeName forKey:@"Theme"];
    self.currentTheme = newThemeName;
    [self reload];
}

@end
