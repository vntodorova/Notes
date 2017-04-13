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
        }
        [self setNewTheme:self.currentTheme];
    }
    return self;
}

- (void)loadLightTheme
{
    [self.styles setObject:[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1] forKey:TABLEVIEW_BACKGROUND_COLOR];
    [self.styles setObject:[UIColor whiteColor] forKey:TABLEVIEW_CELL_COLOR];
    [self.styles setObject:[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1] forKey:NAVIGATION_BAR_COLOR];
    [self.styles setObject:[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1] forKey:BACKGROUND_COLOR];
    [self.styles setObject:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0] forKey:TINT];
    [self.styles setObject:[UIColor whiteColor] forKey:TEXTFIELDS_COLOR];
    [self.styles setObject:[NSNumber numberWithInt:UIBarStyleDefault] forKey:SEARCH_BAR];
    [self.styles setObject:[UIImage imageNamed:@"camera_blue.png"] forKey:CAMERA_IMAGE];
    [self.styles setObject:[UIImage imageNamed:@"drawing_blue.png"] forKey:DRAWING_IMAGE];
    [self.styles setObject:[UIImage imageNamed:@"list_blue.png"] forKey:LIST_IMAGE];
}

- (void)loadDarkTheme
{
    [self.styles setObject:[UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1] forKey:TABLEVIEW_BACKGROUND_COLOR];
    [self.styles setObject:[UIColor colorWithRed:120.0/255.0 green:120.0/255.0 blue:120.0/255.0 alpha:1] forKey:TABLEVIEW_CELL_COLOR];
    [self.styles setObject:[UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1] forKey:NAVIGATION_BAR_COLOR];
    [self.styles setObject:[UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1] forKey:BACKGROUND_COLOR];
    [self.styles setObject:[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1] forKey:TINT];
    [self.styles setObject:[UIColor colorWithRed:120.0/255.0 green:120.0/255.0 blue:120.0/255.0 alpha:1] forKey:TEXTFIELDS_COLOR];
    [self.styles setObject:[NSNumber numberWithInt:UIBarStyleBlack] forKey:SEARCH_BAR];
    [self.styles setObject:[UIImage imageNamed:@"camera_dark.png"] forKey:CAMERA_IMAGE];
    [self.styles setObject:[UIImage imageNamed:@"drawing_dark.png"] forKey:DRAWING_IMAGE];
    [self.styles setObject:[UIImage imageNamed:@"list_dark.png"] forKey:LIST_IMAGE];
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
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.currentTheme = newThemeName;
    [self reload];
}

@end
