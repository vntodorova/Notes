//
//  NoteCreationController.h
//  Notes
//
//  Created by VCS on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"
#import "DatePickerViewController.h"
#import "ExpandingButton.h"

@class LocalNoteManager;

@interface NoteCreationController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate, DatePickerDelegate, DrawingDelegate>

- (instancetype)initWithManager:(LocalNoteManager*) manager;

- (IBAction)alignRightSelected:(id)sender;
- (IBAction)alignLeftSelected:(id)sender;
- (IBAction)alignCenterSelected:(id)sender;

- (IBAction)optionsSelected:(id)sender;
- (IBAction)createSelected:(id)sender;
- (IBAction)lockSelected:(id)sender;

- (IBAction)listSelected:(id)sender;
- (IBAction)underlineSelected:(id)sender;
- (IBAction)italicSelected:(id)sender;
- (IBAction)boldSelected:(id)sender;
- (IBAction)fontSelected:(id)sender;
- (IBAction)sizeSelected:(id)sender;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet ExpandingButton *optionsButton;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIWebView *noteBody;
@property (weak, nonatomic) IBOutlet UITextField *noteTags;
@property (weak, nonatomic) IBOutlet UITextField *noteName;
@property (nonatomic, strong) NSString *currentNotebook;
@property Note *note;

@end
