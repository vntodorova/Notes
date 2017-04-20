//
//  DatePickerViewController.m
//  Notes
//
//  Created by VCS on 4/13/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "DatePickerViewController.h"
#import "ThemeManager.h"
#import "Defines.h"

@interface DatePickerViewController ()
@property ThemeManager *themeManager;
@end

@implementation DatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.themeManager = [ThemeManager sharedInstance];
    [self.view setTintColor:[self.themeManager.styles objectForKey:TINT]];
    [self.view setBackgroundColor:[self.themeManager.styles objectForKey:BACKGROUND_COLOR]];
    [self.datePicker setValue:[self.themeManager.styles objectForKey:TINT] forKey:@"textColor"];
}

- (IBAction)onCancelClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSaveClicked:(id)sender
{
    [self.delegate  reminderDateSelected:[self.datePicker date]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
