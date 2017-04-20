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
#import "LocalNoteManager.h"
#import "DateTimeManager.h"
#import "TagsParser.h"

@interface NoteCreationController ()

@property (nonatomic, assign) IBOutlet UIButton* alignLeftButton;
@property (nonatomic, assign) IBOutlet UIButton* alignCenterButton;
@property (nonatomic, assign) IBOutlet UIButton* alignRightButton;
@property (nonatomic, assign) IBOutlet UIButton* calendarButton;

@property (nonatomic, strong) NSMutableArray *fontList;
@property (nonatomic, strong) NSMutableArray *textSizeList;
@property (nonatomic, strong) NSMutableArray *noteBookList;
@property (nonatomic, strong) LocalNoteManager *manager;
@property (nonatomic, strong) ThemeManager *themeManager;

@property (nonatomic, strong) TagsParser *tagsParser;

@property (nonatomic, strong) NSString *startingNoteName;


@property (nonatomic, assign) int imageIndex;
@property (nonatomic, assign) BOOL isNoteNew;
@end

@implementation NoteCreationController


-(instancetype)initWithManager:(LocalNoteManager *)manager
{
    self = [super self];
    
    self.manager = manager;
    self.tagsParser = [[TagsParser alloc] init];
    self.fontList = [[NSMutableArray alloc] init];
    self.textSizeList = [[NSMutableArray alloc] init];
    self.themeManager = [ThemeManager sharedInstance];
    self.imageIndex = 0;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadTheme];
    [self inflateFontsList];
    [self inflateTextSizeList];
    [self deleteTempFolder];
    [self createTempFolder];
    [self loadHTML];
    [self setupOptionsButton];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                     initWithTarget:self
                                     action:@selector(dismissKeyboard)]];
}

#pragma mark -
#pragma mark ViewController setup

- (void)loadTheme
{
    [self setBarButtonColors];
    self.view.tintColor = [self.themeManager.styles objectForKey:TINT];
    self.view.backgroundColor = [self.themeManager.styles objectForKey:BACKGROUND_COLOR];
    self.toolbar.barTintColor = [self.themeManager.styles objectForKey:NAVIGATION_BAR_COLOR];
    self.optionsButton.tintColor = [self.themeManager.styles objectForKey:TINT];
}

-(void) setBarButtonColors
{
    [self setButton:self.alignCenterButton withImageName:TOOLBAR_ALIGN_CENTER_IMAGE];
    [self setButton:self.alignLeftButton withImageName:TOOLBAR_ALIGN_LEFT_IMAGE];
    [self setButton:self.alignRightButton withImageName:TOOLBAR_ALIGN_RIGHT_IMAGE];
    [self setButton:self.calendarButton withImageName:TOOLBAR_CALENDAR_IMAGE];
}

-(void) setButton:(UIButton*) button withImageName:(NSString*) imageName
{
    UIImage* origImage = [UIImage imageNamed:imageName];
    UIImage* tintedImage = [origImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:tintedImage forState:UIControlStateNormal];
}

-(void) inflateFontsList
{
    [self.fontList addObject:@"Times New Roman"];
    [self.fontList addObject:@"Arial"];
    [self.fontList addObject:@"Futura"];
    [self.fontList addObject:@"Verdana"];
}

-(void) inflateTextSizeList
{
    [self.textSizeList addObject:@"10"];
    [self.textSizeList addObject:@"11"];
    [self.textSizeList addObject:@"12"];
    [self.textSizeList addObject:@"13"];
    [self.textSizeList addObject:@"14"];
}

- (void)setupOptionsButton
{
    [self.optionsButton setup];
    [self.optionsButton addSmallButtonWithAction:@selector(onListClick) target:self andImage:LIST_IMAGE];
    [self.optionsButton addSmallButtonWithAction:@selector(onDrawingClick) target:self andImage:DRAWING_IMAGE];
    [self.optionsButton addSmallButtonWithAction:@selector(onCameraClick) target:self andImage:CAMERA_IMAGE];
}

-(void) deleteTempFolder
{
    [self.manager deleteTempFolder];
}

-(void) createTempFolder
{
    [self.manager createTempFolder];
}

-(void) loadHTML
{
    if(self.note.name.length > 0)
    {
        self.startingNoteName = self.note.name;
        self.isNoteNew = NO;
        [self loadSavedHtml];
        self.noteName.text = self.note.name;
        self.noteTags.text = [self.tagsParser buildTextFromTags:self.note.tags];
        [self.createButton setTitle:REDACTATION_BUTTON_NAME forState:UIControlStateNormal];
    }
    else
    {
        self.isNoteNew = YES;
        [self loadNoteTemplateHTML];
    }
}

#pragma mark -
#pragma mark Options buttons

- (IBAction)onOptionsClick:(ExpandingButton *)sender
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

- (void)onListClick
{
    [self.optionsButton hideOptionsButtons];
    NSLog(@"List clicked");
}

- (void)onCameraClick
{
    [self.optionsButton hideOptionsButtons];
    [self showImagePicker];
}

- (void)onDrawingClick
{
    [self.optionsButton hideOptionsButtons];
    DrawingViewController *drawingViewController = [[DrawingViewController alloc] init];
    [self.navigationController pushViewController:drawingViewController animated:YES];
}

#pragma mark -
#pragma mark Public

- (IBAction)onCreateClick:(id)sender
{
    NSMutableArray *array  = [self getSelectionMenuForList:[self.manager getNotebookNamesList] andSelector:@selector(notebookSelected:)];
    [array addObject:[self getInputAlertAction]];
    [self displaySelectableMenuWithButton:sender list:array];
}

- (IBAction)onAlignCenterPressed:(id)sender
{
    [self alignSelectedTextCenter];
}

- (IBAction)onAlignRightPressed:(id)sender
{
    [self alignSelectedTextRight];
}

- (IBAction)onAlignLeftPressed:(id)sender
{
    [self alignSelectedTextLeft];
}

- (void)notebookSelected:(NSString*) noteBookSelected
{
    [self setNoteContent];
    [self.navigationController popViewControllerAnimated:YES];
    if(![self.startingNoteName isEqualToString:self.note.name])
    {
        [self.manager renameNote:self.note fromNotebookWithName:self.currentNotebook oldName:self.startingNoteName];
    }
    [self.manager addNote:self.note toNotebookWithName:noteBookSelected];
}

- (IBAction)onSettingsSelected:(UIButton*)sender
{
    [self showDatePickerFromButton:sender];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}

- (IBAction)onUnderlineSelected:(id)sender
{
    [self applyUnderlineOnSelectedText];
}

- (IBAction)onItalicStyleSelected:(id)sender
{
    [self applyItalicOnSelectedText];
}

- (IBAction)onBoldStyleSelected:(id)sender
{
    [self applyBoldOnSelectedText];
}

- (IBAction)onFontSelected:(id)sender
{
    NSMutableArray *array  = [self getSelectionMenuForList:self.fontList andSelector:@selector(updateNoteFont:)];
    [self displaySelectableMenuWithButton:sender list:array];
}

- (IBAction)onSizeSelected:(UIButton *)sender
{
    NSMutableArray *array  = [self getSelectionMenuForList:self.textSizeList andSelector:@selector(updateNoteSize:)];
    [self displaySelectableMenuWithButton:sender list:array];
}

#pragma mark -
#pragma mark Private

-(NSMutableArray*) getSelectionMenuForList:(NSArray*) itemList andSelector:(SEL) selector
{
    NSMutableArray *array  = [[NSMutableArray alloc] init];
    
    for (NSString* currentItem in itemList)
    {
        [array addObject:[UIAlertAction actionWithTitle:currentItem style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
            [self performSelector:selector withObject:currentItem];
        }]];
    }
    return array;
}


-(NSMutableArray*) getNotebookSelectionMenu
{
    NSMutableArray *array  = [[NSMutableArray alloc] init];
    
    [array addObject:[self getInputAlertAction]];
    
    for (Notebook* currentItem in [self.manager getNotebookList])
    {
        [array addObject:[UIAlertAction actionWithTitle:currentItem.name style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                          {
                              [self performSelector:@selector(notebookSelected:) withObject:currentItem];
                          }]];
    }
    return array;
}

-(void) showDatePickerFromButton:(UIButton*) sender
{
    DatePickerViewController *datePicker = [[DatePickerViewController alloc] initWithNibName:@"DatePickerViewController" bundle:nil];
    datePicker.delegate = self;
    datePicker.modalPresentationStyle = UIModalPresentationPopover;
    datePicker.preferredContentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height / 2);
    
    UIPopoverPresentationController *popPC = datePicker.popoverPresentationController;
    datePicker.popoverPresentationController.sourceRect = sender.frame;
    datePicker.popoverPresentationController.sourceView = self.view;
    
    popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popPC.delegate = self;
    [self presentViewController:datePicker animated:YES completion:nil];
}

-(void)reminderDateSelected:(NSDate *)date
{
    self.note.triggerDate = date.description;
}

-(void) alignSelectedTextCenter
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:JS_COMMAND_ALIGN_CENTER];
}

-(void) alignSelectedTextRight
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:JS_COMMAND_ALIGN_RIGHT];
}

-(void) alignSelectedTextLeft
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:JS_COMMAND_ALIGN_LEFT];
}

-(void) applyUnderlineOnSelectedText
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:JS_COMMAND_UNDERLINE];
}

-(void) applyBoldOnSelectedText
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:JS_COMMAND_BOLD];
}

-(void) applyItalicOnSelectedText
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:JS_COMMAND_ITALIC];
}

-(void) showImagePicker
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:NO completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *imageName = [NSString stringWithFormat:@"%@.png",[self getCurrentTime]];
    [self.manager saveImage:info withName:imageName forNote:self.note inNotebookWithName:self.currentNotebook];
    [self insertImageAtEndOfWebview:imageName];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


-(void) insertImageAtEndOfWebview:(NSString*) imageName
{
    NSMutableString *noteBody = [[NSMutableString alloc]initWithString:[self getNoteBodyHTML]];
    
    NSString *imageHtml = [NSString stringWithFormat:DEFAULT_IMAGE_HTML, imageName];
    NSRange range = [noteBody rangeOfString:@"</div>"];
    [noteBody insertString:imageHtml atIndex:range.location];
    
    [self refreshWebView:noteBody baseURL:[self.manager getBaseURLforNote:self.note inNotebookWithName:self.currentNotebook]];
}

-(NSString*) getCurrentTime
{
    DateTimeManager *timeManager = [[DateTimeManager alloc] init];
    return [timeManager getCurrentTime];
}

- (void)refreshWebView:(NSString*)noteBody baseURL:(NSURL*) baseURL
{
    [self.noteBody loadHTMLString:noteBody baseURL:baseURL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(NSString*) getNoteBodyHTML
{
    return [self.noteBody stringByEvaluatingJavaScriptFromString:JS_COMMAND_GET_HTML];
}

-(UIAlertAction*) getInputAlertAction
{
    UIAlertAction *newNotebookAction = [UIAlertAction actionWithTitle:ALERT_INPUT_DIALOG_TITLE
                                                                style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction * _Nonnull action)
    {
        [self presentViewController:[self getInputAlertActionController] animated:YES completion:nil];
    }];
    
    return newNotebookAction;
}

-(UIAlertController *) getInputAlertActionController
{
    UIAlertController *inputController = [UIAlertController alertControllerWithTitle:ALERT_INPUT_DIALOG_TITLE
                                                                             message:ALERT_INPUT_DIALOG_MESSAGE
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [inputController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField)
     {
         textField.placeholder = @"Name";
         textField.textColor = [UIColor blueColor];
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

-(void) setNoteContent
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
    
    self.note.dateCreated = [self getCurrentTime];
}

- (void)updateNoteFont:(NSString*) font
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:JS_COMMAND_FONT_TYPE, font]];
}

- (void)updateNoteSize:(NSString*) size
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:JS_COMMAND_FONT_SIZE, size]];
}

-(void) loadNoteTemplateHTML
{
    [self.noteBody loadHTMLString:TEMPLATE_CONTENTS baseURL:nil];
}

-(void) loadSavedHtml
{
    NSURL *baseURL = [self.manager getBaseURLforNote:self.note inNotebookWithName:self.currentNotebook];
    [self.noteBody loadHTMLString:self.note.body baseURL:baseURL];
}

- (void)displaySelectableMenuWithButton:(UIButton *) button list:(NSMutableArray*)nameList
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:ALERT_DIALOG_TITLE
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
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

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

@end
