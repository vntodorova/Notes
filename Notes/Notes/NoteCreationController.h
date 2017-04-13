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
@class LocalNoteManager;

@interface NoteCreationController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, DatePickerDelegate>

- (instancetype)initWithManager:(LocalNoteManager*) manager;

- (IBAction)onAlignCenterPressed:(id)sender;
- (IBAction)onOptionsClick:(id)sender;
- (IBAction)onCreateClick:(id)sender;

- (IBAction)onSettingsSelected:(id)sender;
- (IBAction)onUnderlineSelected:(id)sender;
- (IBAction)onItalicStyleSelected:(id)sender;
- (IBAction)onBoldStyleSelected:(id)sender;
- (IBAction)onFontSelected:(id)sender;
- (IBAction)onSizeSelected:(id)sender;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIButton *optionsButton;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIWebView *noteBody;
@property (weak, nonatomic) IBOutlet UITextField *noteTags;
@property (weak, nonatomic) IBOutlet UITextField *noteName;
@property (nonatomic, strong) NSString *currentNotebook;
@property Note *note;

@end
