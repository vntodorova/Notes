//
//  DatePickerViewController.h
//  Notes
//
//  Created by VCS on 4/13/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickerDelegate

-(void) reminderDateSelected:(NSDate* )date;

@end

@interface DatePickerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak) id<DatePickerDelegate> delegate;

- (IBAction)onCancelClicked:(id)sender;
- (IBAction)onSaveClicked:(id)sender;

@end
