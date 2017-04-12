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

@implementation SettingsPanelViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil manager:(LocalNoteManager *)noteManager
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
    self.view.frame = CGRectMake(-1 * LEFT_PANEL_WIDTH, 0, LEFT_PANEL_WIDTH, self.view.frame.size.height);
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self loadTheme];
}

- (void)loadTheme
{
    self.view.backgroundColor = [self.themeManager.styles objectForKey:BACKGROUND_COLOR];
}

- (IBAction)saveButtonClicked:(UIButton *)sender
{
    NSString *previousTheme = [self.themeManager currentTheme];
    NSInteger row = [self.pickerView selectedRowInComponent:0];
    NSString *chosenTheme = [self.themeManager.themeNames objectAtIndex:row];
    [self.themeManager setCurrentTheme:chosenTheme];
    [UIView animateWithDuration:0.5 animations:^{
        self.isHidden = YES;
        self.view.frame = CGRectMake(-1 * LEFT_PANEL_WIDTH, 0, LEFT_PANEL_WIDTH, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        if(![previousTheme isEqualToString:chosenTheme])
        {
            [self.delegate onThemeChanged];
            [self loadTheme];
        }
    }];
}

- (IBAction)cancelButtonClicked:(UIButton *)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        self.isHidden = YES;
        self.view.frame = CGRectMake(-1 * LEFT_PANEL_WIDTH, 0, LEFT_PANEL_WIDTH, self.view.frame.size.height);
    }];
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

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.themeManager.themeNames objectAtIndex:row];
}


@end
