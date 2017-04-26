//
//  SettingsPanelViewController.h
//  Notes
//
//  Created by Nemetschek A-Team on 4/11/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@class ViewController;
@class ViewController;
@class ThemeManager;
@class NoteManager;

@interface SettingsPanelViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

- (IBAction)saveButtonClicked:(UIButton *)sender;
- (IBAction)cancelButtonClicked:(UIButton *)sender;
- (IBAction)synchronize:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UILabel *synchronizeLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) id <LeftPanelDelegate> delegate;
@property BOOL isHidden;
@property ThemeManager *themeManager;

@end
