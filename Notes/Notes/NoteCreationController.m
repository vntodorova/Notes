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
@property (nonatomic, strong) NSString *tempFolderPath;

@property (nonatomic, strong) UIButton *addImageButton;
@property (nonatomic, strong) UIButton *addDrawingButton;
@property (nonatomic, strong) UIButton *addListButton;

@property BOOL optionsButtonsHidden;
@property int imageIndex;

@property BOOL isNoteNew;
@end

@implementation NoteCreationController


-(instancetype)initWithManager:(LocalNoteManager *)manager
{
    self = [super self];
    
    self.manager = manager;
    self.tempFolderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                           stringByAppendingPathComponent:TEMP_FOLDER];
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
    [self setupOptionsButtons];
    [self deleteTempFolder];
    [self createTempFolder];
    [self loadHTML];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                     initWithTarget:self
                                     action:@selector(dismissKeyboard)]];
}

#pragma mark -
#pragma mark ViewController setup

- (void)loadTheme
{
    self.view.tintColor = [self.themeManager.styles objectForKey:TINT];
    self.view.backgroundColor = [self.themeManager.styles objectForKey:BACKGROUND_COLOR];
    self.toolbar.barTintColor = [self.themeManager.styles objectForKey:NAVIGATION_BAR_COLOR];
    self.optionsButton.tintColor = [self.themeManager.styles objectForKey:TINT];
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

- (void)setupOptionsButtons
{
    self.optionsButtonsHidden = YES;
    CGFloat red, green, blue;
    [[self.themeManager.styles objectForKey:TINT] getRed:&red green:&green blue:&blue alpha:nil];
    self.addImageButton = [self getButtonWithAction:@selector(onCameraClick) andImage:CAMERA_IMAGE];
    self.addListButton = [self getButtonWithAction:@selector(onListClick) andImage:LIST_IMAGE];
    self.addDrawingButton = [self getButtonWithAction:@selector(onDrawingClick) andImage:DRAWING_IMAGE];
}

- (UIButton *)getButtonWithAction:(SEL)selector andImage:(NSString *)imageName
{
    CGFloat red, green, blue;
    [[self.themeManager.styles objectForKey:TINT] getRed:&red green:&green blue:&blue alpha:nil];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 23;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor colorWithRed:red green:green blue:blue alpha:1].CGColor;
    button.clipsToBounds = YES;
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[self.themeManager.styles objectForKey:imageName] forState:UIControlStateNormal];
    button.layer.backgroundColor = [UIColor darkGrayColor].CGColor;
    return button;
}

-(void) deleteTempFolder
{
    [[NSFileManager defaultManager] removeItemAtPath:self.tempFolderPath error:nil];
}

-(void) createTempFolder
{
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:self.tempFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
}

-(void) loadHTML
{
    if(self.note.name.length > 0)
    {
        self.isNoteNew = NO;
        [self loadSavedHtml];
        self.noteName.text = self.note.name;
        self.noteTags.text = [self buildTextFromTags: self.note.tags];
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

- (IBAction)onOptionsClick:(UIButton *)sender
{
    if(self.optionsButtonsHidden)
    {
        [self showOptionsButtons];
    }
    else
    {
        [self hideOptionsButtons];
    }
}

- (void)showOptionsButtons
{
    CGFloat optionsButtonFrameX = self.optionsButton.frame.origin.x;
    CGFloat optionsButtonFrameY = self.optionsButton.frame.origin.y;
    long optionsButtonX = optionsButtonFrameX - SMALL_BUTTON_DISTANCE;
    long optionsButtonY = optionsButtonFrameY - SMALL_BUTTON_DISTANCE;
    CGRect newImageButtonFrame = CGRectMake(optionsButtonX, optionsButtonY, SMALL_BUTTONS_WIDTH, SMALL_BUTTONS_HEIGHT);
    optionsButtonY = optionsButtonFrameY - 10;
    CGRect newDrawingButtonFrame = CGRectMake(optionsButtonX, optionsButtonY, SMALL_BUTTONS_WIDTH, SMALL_BUTTONS_HEIGHT);
    optionsButtonX = optionsButtonFrameX - 10;
    optionsButtonY = optionsButtonFrameY - SMALL_BUTTON_DISTANCE;
    CGRect newListButtonFrame = CGRectMake(optionsButtonX, optionsButtonY, SMALL_BUTTONS_WIDTH, SMALL_BUTTONS_HEIGHT);
        
    CGRect initialFrame = CGRectMake(optionsButtonFrameX + SMALL_BUTTON_DISTANCE / 2, optionsButtonFrameY + SMALL_BUTTON_DISTANCE / 2, 0, 0);
        
    self.addImageButton.frame = initialFrame;
    self.addDrawingButton.frame = initialFrame;
    self.addListButton.frame = initialFrame;
        
    [self.view addSubview:self.addImageButton];
    [self.view addSubview:self.addDrawingButton];
    [self.view addSubview:self.addListButton];
        
    [UIView animateWithDuration:0.5
                        animations:^
    {
             self.addImageButton.frame = newImageButtonFrame;
             self.addDrawingButton.frame = newDrawingButtonFrame;
             self.addListButton.frame = newListButtonFrame;
    }];
        self.optionsButtonsHidden = NO;
}

- (void)hideOptionsButtons
{
    CGRect newFrame = CGRectMake(self.optionsButton.frame.origin.x + SMALL_BUTTON_DISTANCE / 2, self.optionsButton.frame.origin.y + SMALL_BUTTON_DISTANCE / 2, 0, 0);
    [UIView animateWithDuration:0.5
                     animations:^
     {
         self.addListButton.frame = newFrame;
         self.addDrawingButton.frame = newFrame;
         self.addImageButton.frame = newFrame;
     }
                     completion:^(BOOL finished)
     {
         [self.addListButton removeFromSuperview];
         [self.addDrawingButton removeFromSuperview];
         [self.addImageButton removeFromSuperview];
     }];
    self.optionsButtonsHidden = YES;
}

- (void)onListClick
{
    [self hideOptionsButtons];
    NSLog(@"List clicked");
}

- (void)onCameraClick
{
    [self hideOptionsButtons];
    [self showImagePicker];
}

- (void)onDrawingClick
{
    [self hideOptionsButtons];
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

-(UIButton*) getExpandingButtonWithImage:(NSString*) image andSelector:(SEL) selector
{
    UIButton *button = [[UIButton alloc] init];
    self.optionsButtonsHidden = YES;
    CGFloat red, green, blue;
    [[self.themeManager.styles objectForKey:TINT] getRed:&red green:&green blue:&blue alpha:nil];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 23;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor colorWithRed:red green:green blue:blue alpha:1].CGColor;
    button.clipsToBounds = YES;
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[self.themeManager.styles objectForKey:image] forState:UIControlStateNormal];
    return button;
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
    [self setNoteReminderDate:date];
}

-(void) setNoteReminderDate:(NSDate*)date
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
    NSString *imageName = [NSString stringWithFormat:@"%@.png", [self getCurrentTime]];
    NSString *imagePath;
    if(self.isNoteNew)
    {
        imagePath = [self.tempFolderPath stringByAppendingPathComponent:imageName];
    }
    else
    {
        imagePath = [[self getNoteDirectoryPathForNote:self.note inNotebookWithName:self.currentNotebook] stringByAppendingPathComponent:imageName];
    }
    [self saveImage:info imagePath:imagePath];
    [self insertImageAtEndOfWebview:imageName];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(NSString*) getCurrentTime
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:TIME_DATE_FORMAT];
    return [dateFormatter stringFromDate:[NSDate date]];
}

-(void) saveImage:(NSDictionary*) imageInfo imagePath:(NSString*) imagePath
{
    NSString *mediaType = [imageInfo objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:PUBLIC_IMAGE_IDENTIFIER])
    {
        UIImage *image = [imageInfo objectForKey:UIImagePickerControllerOriginalImage];
        NSData *data = UIImagePNGRepresentation(image);
        [data writeToFile:imagePath atomically:YES];
    }
}

-(void) insertImageAtEndOfWebview:(NSString*) imagePath
{
    NSMutableString *noteBody = [[NSMutableString alloc]initWithString:[self getNoteBodyHTML]];
    
    NSString *imageHtml = [NSString stringWithFormat:DEFAULT_IMAGE_HTML, imagePath];
    NSRange range = [noteBody rangeOfString:@"</div>"];
    [noteBody insertString:imageHtml atIndex:range.location];
    if(self.isNoteNew)
    {
        [self refreshWebView:noteBody baseURL:[NSURL fileURLWithPath:self.tempFolderPath]];
    }
    else
    {
        [self refreshWebView:noteBody baseURL:[NSURL fileURLWithPath:[self getNoteDirectoryPathForNote:self.note
                                                                                  inNotebookWithName:self.currentNotebook]]];
    }
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
    
    self.note.tags = [self getTagsFromText:self.noteTags.text];
    self.note.body = [self changeHTMLImagePathsToLocal:[self getNoteBodyHTML]];
    
    self.note.dateCreated = [self getCurrentTime];
}

-(NSString*) changeHTMLImagePathsToLocal:(NSString*) html
{
    NSString *notePath = [self getNoteDirectoryPathForNote:self.note inNotebookWithName:self.currentNotebook];
    NSString *stringForReplace = [self.tempFolderPath stringByAppendingString:@"/"];
    html = [html stringByReplacingOccurrencesOfString:stringForReplace withString:@""];
    
    stringForReplace = [notePath stringByAppendingString:@"/"];
    html = [html stringByReplacingOccurrencesOfString:stringForReplace withString:@""];
    
    return html;
}

-(NSString*) getNoteDirectoryPathForNote:(Note*)note inNotebookWithName:(NSString*) notebook
{
    return [[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
              stringByAppendingPathComponent:NOTE_NOTEBOOKS_FOLDER]
             stringByAppendingPathComponent:notebook]
            stringByAppendingPathComponent:note.name];
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
    NSString *loadedFilePath = [[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                                  stringByAppendingPathComponent:NOTE_NOTEBOOKS_FOLDER]
                                 stringByAppendingPathComponent:self.currentNotebook]
                                stringByAppendingPathComponent:self.note.name];

    NSURL *baseURL = [NSURL fileURLWithPath:loadedFilePath];
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

- (NSArray *)getTagsFromText:(NSString *) tagsText
{
    NSArray *tagList;
    NSCharacterSet *setOfIndicators = [NSCharacterSet characterSetWithCharactersInString:TAG_SEPARATION_INDICATORS];
    tagList = [tagsText componentsSeparatedByCharactersInSet:setOfIndicators];
    NSMutableArray *clearTagList = [[NSMutableArray alloc] init];
    
    for(NSString *tag in tagList)
    {
        if([tag isEqualToString:@""])
        {
            continue;
        }
        [clearTagList addObject:tag];
    }
    return clearTagList;
}

-(NSString *) buildTextFromTags:(NSArray *)tagsList
{
    NSMutableString *tagsText = [[NSMutableString alloc] init];
    for(NSString *tag in tagsList)
    {
        [tagsText appendFormat:@"#%@ ",tag];
    }
    return tagsText;
}
@end
