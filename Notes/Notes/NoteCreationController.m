//
//  NoteCreationController.m
//  Notes
//
//  Created by VCS on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "NoteCreationController.h"
#import "Defines.h"
#import "Notebook.h"
#import "DrawingViewController.h"
#import "ThemeManager.h"
#import "LayoutProvider.h"
#import "Note.h"
#import "NoteManager.h"
#import "DateTimeManager.h"
#import "TagsParser.h"

@interface NoteCreationController ()

@property (nonatomic, strong) NSArray *fontList;
@property (nonatomic, strong) NSArray *textSizeList;
@property (nonatomic, strong) NSMutableArray *noteBookList;
@property (nonatomic, assign) NoteManager *manager;
@property (nonatomic, strong) ThemeManager *themeManager;

@property (nonatomic, strong) TagsParser *tagsParser;
@property (nonatomic, strong) NSString *tempNoteReminder;
@property (nonatomic, strong) NSString *startingNoteName;

@property BOOL keyboardIsShown;
@property CGRect keyboardFrame;
@end

@implementation NoteCreationController


- (instancetype)initWithManager:(NoteManager *)manager
{
    self = [super self];
    self.manager = manager;
    self.tagsParser = [[TagsParser alloc] init];
    self.fontList = [[NSArray alloc] initWithObjects:TIMES_NEW_ROMAN, ARIAL, FUTURA, VERDANA, nil];
    self.textSizeList = [[NSArray alloc] initWithObjects:@"10", @"11", @"12", @"13", @"14", nil];
    self.themeManager = [ThemeManager sharedInstance];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadTheme];
    [self deleteTempFolder];
    [self createTempFolder];
    [self loadHTML];
    [self setupOptionsButton];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                     initWithTarget:self
                                     action:@selector(dismissKeyboard)]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self.manager requestNotebookList];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self dismissKeyboard];
}

#pragma mark -
#pragma mark ViewController setup

- (void)loadTheme
{
    [self.view setTintColor:[self.themeManager.styles objectForKey:TINT]];
    [self.view setBackgroundColor:[self.themeManager.styles objectForKey:BACKGROUND_COLOR]];
    [self.toolbar setBarTintColor:[self.themeManager.styles objectForKey:NAVIGATION_BAR_COLOR]];
    [self.optionsButton setTintColor:[self.themeManager.styles objectForKey:TINT]];
}

- (void)setupOptionsButton
{
    [self.optionsButton setup];
    [self.optionsButton addSmallButtonWithAction:@selector(reminderSelected) target:self andImage:REMINDER_IMAGE];
    [self.optionsButton addSmallButtonWithAction:@selector(drawingSelected) target:self andImage:DRAWING_IMAGE];
    [self.optionsButton addSmallButtonWithAction:@selector(cameraSelected) target:self andImage:CAMERA_IMAGE];
}

- (void)deleteTempFolder
{
    [self.manager deleteTempFolder];
}

- (void)createTempFolder
{
    [self.manager createTempFolder];
}

- (void)loadHTML
{
    if(self.note.name.length > 0)
    {
        [self setStartingNoteName:self.note.name];
        [self loadSavedHtml];
        [self.noteName setText:self.note.name];
        [self.noteTags setText:[self.tagsParser buildTextFromTags:self.note.tags]];
        [self.createButton setTitle:SAVE_BUTTON_NAME forState:UIControlStateNormal];
    }
    else
    {
        [self loadNoteTemplateHTML];
    }
}

#pragma mark -
#pragma mark Private methods

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}

- (void)notebookSelected:(NSString *)noteBookSelected
{
    [self setNoteContent];
    [self.navigationController popViewControllerAnimated:YES];
    
    if(![noteBookSelected isEqualToString:self.currentNotebook])
    {
        [self.manager copyNote:self.note fromNotebookWithName:self.currentNotebook toNotebookWithName:noteBookSelected];
        return;
    }
    if(![self.startingNoteName isEqualToString:self.note.name] && self.startingNoteName != nil)
    {
        [self.manager renameNote:self.note fromNotebookWithName:self.currentNotebook oldName:self.startingNoteName];
    }
    [self.manager addNote:self.note toNotebookWithName:noteBookSelected];
}

- (NSString *)currentTime
{
    return [[DateTimeManager sharedInstance] getCurrentTime];
}

- (NSMutableArray *)selectionMenuForList:(NSArray *)itemList andSelector:(SEL)selector
{
    NSMutableArray *array  = [[NSMutableArray alloc] init];
    
    for (NSString* currentItem in itemList)
    {
        [array addObject:[UIAlertAction actionWithTitle:currentItem style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action)
                          {
                              [self performSelector:selector withObject:currentItem];
                          }]];
    }
    return array;
}

- (NSString *)getNoteBodyHTML
{
    return [self.noteBody stringByEvaluatingJavaScriptFromString:JS_COMMAND_GET_HTML];
}

- (void)setNoteContent
{
    if(self.noteName.text.length > 0)
    {
        self.note.name = self.noteName.text;
    }
    else
    {
        self.note.name = UNNAMED_NOTE;
    }
    
    self.note.tags = [self.tagsParser getTagsFromText:self.noteTags.text];
    self.note.body = [self getNoteBodyHTML];
    self.note.triggerDate = self.tempNoteReminder;
    self.note.dateModified = [self currentTime];
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark Toolbar buttons

- (IBAction)alignCenterSelected:(id)sender
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:JS_COMMAND_ALIGN_CENTER];
}

- (IBAction)alignRightSelected:(id)sender
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:JS_COMMAND_ALIGN_RIGHT];
}

- (IBAction)alignLeftSelected:(id)sender
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:JS_COMMAND_ALIGN_LEFT];
}

- (IBAction)listSelected:(id)sender
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:JS_COMMAND_CHECKBOX];
}

- (IBAction)underlineSelected:(id)sender
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:JS_COMMAND_UNDERLINE];
}

- (IBAction)italicSelected:(id)sender
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:JS_COMMAND_ITALIC];
}

- (IBAction)boldSelected:(id)sender
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:JS_COMMAND_BOLD];
}

- (IBAction)fontSelected:(id)sender
{
    NSMutableArray *array  = [self selectionMenuForList:self.fontList andSelector:@selector(updateNoteFont:)];
    [self displaySelectableMenuWithButton:sender list:array];
}

- (IBAction)sizeSelected:(id)sender
{
    NSMutableArray *array  = [self selectionMenuForList:self.textSizeList andSelector:@selector(updateNoteSize:)];
    [self displaySelectableMenuWithButton:sender list:array];
}

#pragma mark -
#pragma mark Bottom bar buttons

- (IBAction)createSelected:(id)sender
{
    NSMutableArray *array  = [self selectionMenuForList:[self.manager getNotebookNamesList] andSelector:@selector(notebookSelected:)];
    [array addObject:[self getInputAlertAction]];
    [self displaySelectableMenuWithButton:sender list:array];
}


- (IBAction)lockSelected:(id)sender
{
    [self toggleWebViewForEditing];
}

#pragma mark -
#pragma mark Hidden buttons

- (IBAction)optionsSelected:(id)sender
{
    if(self.optionsButton.isExpanded)
    {
        [self.optionsButton hideOptionsButtons];
    }
    else
    {
        [self.optionsButton showOptionsButtons];
    }
}

- (void)reminderSelected
{
    [self.optionsButton hideOptionsButtons];
    [self showDatePickerFromButton:self.optionsButton];
}

- (void)cameraSelected
{
    [self.optionsButton hideOptionsButtons];
    [self showImagePicker];
}

- (void)drawingSelected
{
    [self.optionsButton hideOptionsButtons];
    DrawingViewController *drawingViewController = [[DrawingViewController alloc] init];
    drawingViewController.delegate = self;
    [self.navigationController pushViewController:drawingViewController animated:YES];
}

#pragma mark -
#pragma mark Webview editing methods

- (void)insertImageAtEndOfWebview:(NSString *)imageName
{
    NSMutableString *noteBody = [[NSMutableString alloc]initWithString:[self getNoteBodyHTML]];
    
    NSString *imageHtml = [NSString stringWithFormat:DEFAULT_IMAGE_HTML, imageName];
    NSRange range = [noteBody rangeOfString:@"</div>"];
    [noteBody insertString:imageHtml atIndex:range.location];
    
    [self refreshWebView:noteBody baseURL:[self.manager getBaseURLforNote:self.note inNotebookWithName:self.currentNotebook]];
}

- (void)updateNoteFont:(NSString*) font
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:JS_COMMAND_FONT_TYPE, font]];
}

- (void)updateNoteSize:(NSString*) size
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:JS_COMMAND_FONT_SIZE, size]];
}

- (void)loadNoteTemplateHTML
{
    [self.noteBody loadHTMLString:TEMPLATE_CONTENTS baseURL:nil];
}

- (void)loadSavedHtml
{
    NSURL *baseURL = [self.manager getBaseURLforNote:self.note inNotebookWithName:self.currentNotebook];
    [self.noteBody loadHTMLString:self.note.body baseURL:baseURL];
}

- (void)toggleWebViewForEditing
{
    NSMutableString *noteBody = [[NSMutableString alloc]initWithString:[self getNoteBodyHTML]];
    NSRange range = [noteBody rangeOfString:@"contenteditable=\"true\""];
    if(range.location == NSNotFound)
    {
        range = [noteBody rangeOfString:@"contenteditable=\"false\""];
        [noteBody replaceCharactersInRange:range withString:@"contenteditable=\"true\""];
    }
    else
    {
        [noteBody replaceCharactersInRange:range withString:@"contenteditable=\"false\""];
    }
    [self refreshWebView:noteBody baseURL:[self.manager getBaseURLforNote:self.note inNotebookWithName:self.currentNotebook]];
}

- (void)refreshWebView:(NSString *)noteBody baseURL:(NSURL *)baseURL
{
    [self.noteBody loadHTMLString:noteBody baseURL:baseURL];
}

#pragma mark -
#pragma mark ImagePicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *imageName = [NSString stringWithFormat:@"%@.png",[self currentTime]];
    [self.manager saveImage:info withName:imageName forNote:self.note inNotebookWithName:self.currentNotebook];
    [self insertImageAtEndOfWebview:imageName];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)showImagePicker
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:NO completion:nil];
}

#pragma mark -
#pragma mark DatePicker delegate

- (void)reminderDateSelected:(NSDate *)date
{
    self.tempNoteReminder = date.description;
}

- (void)showDatePickerFromButton:(UIButton *)sender
{
    DatePickerViewController *datePicker = [[DatePickerViewController alloc] initWithNibName:@"DatePickerViewController" bundle:nil];
    datePicker.delegate = self;
    datePicker.modalPresentationStyle = UIModalPresentationPopover;
    datePicker.preferredContentSize = CGSizeMake(500, 300);
    
    UIPopoverPresentationController *popPC = datePicker.popoverPresentationController;
    datePicker.popoverPresentationController.sourceRect = sender.frame;
    datePicker.popoverPresentationController.sourceView = self.view;
    
    popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popPC.delegate = self;
    [self presentViewController:datePicker animated:YES completion:nil];
}

#pragma mark -
#pragma mark DrawingDelegate

- (void)drawingSavedAsImage:(UIImage *)image
{
    NSString *imageName = [NSString stringWithFormat:@"%@.png",[self currentTime]];
    [self.manager saveUIImage:image withName:imageName forNote:self.note inNotebookWithName:self.currentNotebook];
    [self insertImageAtEndOfWebview:imageName];
}

#pragma mark -
#pragma mark AlertController methods

- (UIAlertAction *)getInputAlertAction
{
    UIAlertAction *newNotebookAction = [UIAlertAction actionWithTitle:ALERT_INPUT_DIALOG_TITLE
                                                                style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction * _Nonnull action)
                                        {
                                            [self presentViewController:[self getInputAlertActionController] animated:YES completion:nil];
                                        }];
    
    return newNotebookAction;
}

- (UIAlertController *)getInputAlertActionController
{
    UIAlertController *inputController = [UIAlertController alertControllerWithTitle:ALERT_INPUT_DIALOG_TITLE
                                                                             message:ALERT_INPUT_DIALOG_MESSAGE
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [inputController.view setTintColor:[self.themeManager.styles objectForKey:ALERTCONTROLLER_TINT]];
    [inputController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField)
     {
         textField.placeholder = @"Name";
         textField.textColor = [self.themeManager.styles objectForKey:ALERTCONTROLLER_TINT];
         textField.clearButtonMode = UITextFieldViewModeWhileEditing;
         textField.borderStyle = UITextBorderStyleRoundedRect;
     }];
    
    [inputController addAction:[UIAlertAction actionWithTitle:ALERT_INPUT_DIALOG_CONFIRM_BUTTON_NAME
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action)
                                {
                                    NSArray<UITextField*> *textFields = inputController.textFields;
                                    NSString *textFromField = textFields[0].text;
                                    if([textFromField isEqualToString:@""])
                                    {
                                        textFromField = @"Unknown";
                                    }
                                    Notebook *newNotebook = [[Notebook alloc] initWithName:textFromField];
                                    [self.manager addNotebook:newNotebook];
                                    [self notebookSelected:newNotebook.name];
                                }]];
    
    [inputController addAction:[UIAlertAction actionWithTitle:ALERT_DIALOG_CANCEL_BUTTON_NAME style:UIAlertActionStyleCancel handler:nil]];
    
    return inputController;
}

- (void)displaySelectableMenuWithButton:(UIButton *)button list:(NSMutableArray *)nameList
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:ALERT_DIALOG_TITLE
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert.view setTintColor:[self.themeManager.styles objectForKey:ALERTCONTROLLER_TINT]];
    [alert addAction:[UIAlertAction actionWithTitle:ALERT_DIALOG_CANCEL_BUTTON_NAME style:UIAlertActionStyleCancel handler:nil]];
    
    for (UIAlertAction* currentItem in nameList)
    {
        [alert addAction:currentItem];
    }
    
    UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
    popPresenter.sourceView = button;
    popPresenter.sourceRect = button.bounds;
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -
#pragma mark Keyboard notifications

- (void)keyboardDidShow:(NSNotification *)notification
{
    if(!self.keyboardIsShown)
    {
        self.keyboardFrame = [[[notification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect viewFrame = self.view.frame;
        viewFrame.size.height -= self.keyboardFrame.size.height;
        self.view.frame = viewFrame;
    }
    self.keyboardIsShown = YES;
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    if(self.keyboardIsShown)
    {
        CGRect viewFrame = self.view.frame;
        viewFrame.size.height += self.keyboardFrame.size.height;
        self.view.frame = viewFrame;
    }
    self.keyboardIsShown = NO;
}

@end
