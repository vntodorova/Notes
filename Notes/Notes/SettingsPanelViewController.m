//
//  SettingsPanelViewController.m
//  Notes
//
//  Created by Nemetschek A-Team on 4/11/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "Defines.h"
#import "SettingsPanelViewController.h"
#import "ThemeManager.h"
#import "LayoutProvider.h"

@interface SettingsPanelViewController()

@property LayoutProvider *layoutProvider;

@end

@implementation SettingsPanelViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.isHidden = YES;
        self.themeManager = [ThemeManager sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = CGRectMake(-1 * LEFT_PANEL_WIDTH, 0, LEFT_PANEL_WIDTH, self.layoutProvider.screenSize.height);
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    if([self.themeManager.currentTheme isEqualToString:LIGHT_THEME])
    {
        [self.pickerView selectRow:0 inComponent:0 animated:YES];
    }
    else
    {
        [self.pickerView selectRow:1 inComponent:0 animated:YES];
    }
    self.layoutProvider = [LayoutProvider sharedInstance];
    [self loadTheme];
}

- (void)loadTheme
{
    self.view.backgroundColor = [self.themeManager.styles objectForKey:BACKGROUND_COLOR];
    [self.view setTintColor:[self.themeManager.styles objectForKey:TINT]];
    [self.textLabel setTextColor:[self.themeManager.styles objectForKey:TINT]];
    [self.pickerView reloadAllComponents];
}

- (IBAction)saveButtonClicked:(UIButton *)sender
{
    NSString *previousTheme = [self.themeManager currentTheme];
    NSInteger row = [self.pickerView selectedRowInComponent:0];
    NSString *chosenTheme = [self.themeManager.themeNames objectAtIndex:row];
    if(![previousTheme isEqualToString:chosenTheme])
    {
        [self.themeManager setNewTheme:chosenTheme];
        [[NSNotificationCenter defaultCenter] postNotificationName:THEME_CHANGED_EVENT object:nil userInfo:nil];
        [self loadTheme];
    }
    [self dismiss];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.5 animations:^{
        self.isHidden = YES;
        self.view.frame = CGRectMake(-1 * LEFT_PANEL_WIDTH, 0, LEFT_PANEL_WIDTH, self.view.frame.size.height);
    }];
}

- (IBAction)cancelButtonClicked:(UIButton *)sender
{
    [self dismiss];
}

- (IBAction)synchronize:(UIButton *)sender
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCHRONIZATION object:nil userInfo:nil];
}

#pragma mark -
#pragma mark PickerView delegates

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.themeManager.themeNames count];
}

-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [self.themeManager.themeNames objectAtIndex:row];
    NSAttributedString *attString =
    [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[self.themeManager.styles objectForKey:TINT]}];
    
    return attString;
}


@end
