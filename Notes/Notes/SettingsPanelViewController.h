//
//  SettingsPanelViewController.h
//  Notes
//
//  Created by Nemetschek A-Team on 4/11/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "ViewController.h"

@class ThemeManager;

@interface SettingsPanelViewController : ViewController <UIPickerViewDelegate, UIPickerViewDataSource>

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil manager:(LocalNoteManager *)noteManager;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
- (IBAction)saveButtonClicked:(UIButton *)sender;
- (IBAction)cancelButtonClicked:(UIButton *)sender;

@property (nonatomic, weak) id <LeftPanelDelegate> delegate;

@property BOOL isHidden;
@property ThemeManager *themeManager;

@end
