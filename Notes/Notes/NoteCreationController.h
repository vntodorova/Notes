//
//  NoteCreationController.h
//  Notes
//
//  Created by VCS on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"
#import "LocalNoteManager.h"

@interface NoteCreationController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

-(instancetype)initWithManager:(LocalNoteManager*) manager;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (weak, nonatomic) IBOutlet UIWebView *noteBody;

@property (weak, nonatomic) IBOutlet UITextField *noteTags;

@property (weak, nonatomic) IBOutlet UITextField *noteName;

@property (nonatomic, strong) NSString *currentNotebook;

@property Note *note;

- (IBAction)onOptionsClick:(id)sender;

- (IBAction)onCreateClick:(id)sender;

//Toolbar buttons
- (IBAction)onSettingsSelected:(id)sender;

- (IBAction)onUnderlineSelected:(id)sender;

- (IBAction)onItalicStyleSelected:(id)sender;

- (IBAction)onBoldStyleSelected:(id)sender;

- (IBAction)onFontSelected:(id)sender;

- (IBAction)onSizeSelected:(id)sender;
//------------------
@end
