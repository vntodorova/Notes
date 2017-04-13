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
    UIColor *mainColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1];
    UIColor *textColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    [searchBar setBarStyle:UIBarStyleDefault];
    UIImage *cameraImage = [UIImage imageNamed:@"camera_blue.png"];
    UIImage *drawingImage = [UIImage imageNamed:@"drawing_blue.png"];
    UIImage *listImage = [UIImage imageNamed:@"list_blue.png"];
    [self.styles setObject:mainColor forKey:TABLEVIEW_BACKGROUND_COLOR];
    [self.styles setObject:[UIColor whiteColor] forKey:TABLEVIEW_CELL_COLOR];
    [self.styles setObject:mainColor forKey:NAVIGATION_BAR_COLOR];
    [self.styles setObject:mainColor forKey:BACKGROUND_COLOR];
    [self.styles setObject:textColor forKey:TINT];
    [self.styles setObject:[NSNumber numberWithFloat:1.0] forKey:TEXTFIELDS_ALPHA];
    [self.styles setObject:searchBar forKey:SEARCH_BAR];
    [self.styles setObject:cameraImage forKey:CAMERA_IMAGE];
    [self.styles setObject:drawingImage forKey:DRAWING_IMAGE];
    [self.styles setObject:listImage forKey:LIST_IMAGE];
}

- (void)loadDarkTheme
{
    UIColor *mainColor = [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1];
    UIColor *textColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1];
    UIColor *tableViewCellColor = [UIColor colorWithRed:120.0/255.0 green:120.0/255.0 blue:120.0/255.0 alpha:1];
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    [searchBar setBarStyle:UIBarStyleBlack];
    UIImage *cameraImage = [UIImage imageNamed:@"camera_dark.png"];
    UIImage *drawingImage = [UIImage imageNamed:@"drawing_dark.png"];
    UIImage *listImage = [UIImage imageNamed:@"list_dark.png"];
    [self.styles setObject:mainColor forKey:TABLEVIEW_BACKGROUND_COLOR];
    [self.styles setObject:tableViewCellColor forKey:TABLEVIEW_CELL_COLOR];
    [self.styles setObject:mainColor forKey:NAVIGATION_BAR_COLOR];
    [self.styles setObject:mainColor forKey:BACKGROUND_COLOR];
    [self.styles setObject:textColor forKey:TINT];
    [self.styles setObject:[NSNumber numberWithFloat:0.4] forKey:TEXTFIELDS_ALPHA];
    [self.styles setObject:searchBar forKey:SEARCH_BAR];
    [self.styles setObject:cameraImage forKey:CAMERA_IMAGE];
    [self.styles setObject:drawingImage forKey:DRAWING_IMAGE];
    [self.styles setObject:listImage forKey:LIST_IMAGE];
}

- (void)reload
{
    if([self.currentTheme isEqualToString:LIGHT_THEME])
    {
        [self loadLightTheme];
    } else if([self.currentTheme isEqualToString:DARK_THEME])
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
