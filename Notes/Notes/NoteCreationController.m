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
#import "LocalNoteManager.h"
#import "Note.h"

@interface NoteCreationController ()

@property (nonatomic, strong) NSMutableArray *hiddenButtonsList;
@property (nonatomic, strong) NSMutableArray *fontList;
@property (nonatomic, strong) NSMutableArray *textSizeList;
@property (nonatomic, strong) NSMutableArray *noteBookList;
@property (nonatomic, strong) LocalNoteManager *manager;
@property (nonatomic, strong) ThemeManager *themeManager;
@property (nonatomic, strong) NSString *tempFolderPath;

@property int imageIndex;
@end

@implementation NoteCreationController

#pragma mark Controller

-(instancetype)initWithManager:(LocalNoteManager *)manager
{
    self = [super self];
    
    self.manager = manager;
    self.tempFolderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:TEMP_FOLDER];
    self.hiddenButtonsList = [[NSMutableArray alloc] init];
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
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                     initWithTarget:self
                                             action:@selector(dismissKeyboard)]];
}

-(void) loadHTML
{
    if(self.note.name.length > 0)
    {
        [self loadSavedHtml];
        self.noteName.text = self.note.name;
        self.noteTags.text = [self buildTextFromTags: self.note.tags];
        [self.createButton setTitle:REDACTATION_BUTTON_NAME forState:UIControlStateNormal];
    }
    else
    {
        [self loadNoteTemplateHTML];
    }
}

- (void)loadTheme
{
    self.view.backgroundColor = [self.themeManager.styles objectForKey:BACKGROUND_COLOR];
    [self.toolbar setBarTintColor:[self.themeManager.styles objectForKey:NAVIGATION_BAR_COLOR]];
    [self.noteBody setAlpha:[[self.themeManager.styles objectForKey:TEXTFIELDS_ALPHA] floatValue]];
    [self.noteName setAlpha:[[self.themeManager.styles objectForKey:TEXTFIELDS_ALPHA] floatValue]];
    [self.noteTags setAlpha:[[self.themeManager.styles objectForKey:TEXTFIELDS_ALPHA] floatValue]];
    [self.view setTintColor:[self.themeManager.styles objectForKey:TEXT_COLOR]];
    [self.optionsButton setTintColor:[self.themeManager.styles objectForKey:TEXT_COLOR]];
}

-(void) loadNoteTemplateHTML
{
    NSString *emptyFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                               stringByAppendingPathComponent:EMPTY_FILE_NAME];
    
    NSURL *emptyFileURL = [[NSURL alloc] initWithString:emptyFilePath];
    [self.noteBody loadRequest:[NSURLRequest requestWithURL:emptyFileURL]];
}

-(void) loadSavedHtml
{
    NSString *convertedHTML = [self convertLoadableStringHTML:self.note.body];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [self.noteBody loadHTMLString:convertedHTML baseURL:baseURL];
}

-(NSString*) convertLoadableStringHTML:(NSString *)html
{
    NSString *convertedHTML = html.description;
    
    NSString *loadedFilePath = [[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                                    stringByAppendingPathComponent:NOTE_NOTEBOOKS_FOLDER]
                                    stringByAppendingPathComponent:self.currentNotebook]
                                    stringByAppendingPathComponent:self.note.name];
    
    NSString *stringForReplace = START_OF_IMAGE_HTML;
    NSString *stringReplaced = [NSString stringWithFormat:@"%@%@/", stringForReplace, loadedFilePath];
    
    convertedHTML = [convertedHTML stringByReplacingOccurrencesOfString:stringForReplace withString:stringReplaced];
    return convertedHTML;
}

-(void) createTempFolder
{
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:self.tempFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
}

-(void) deleteTempFolder
{
    [[NSFileManager defaultManager] removeItemAtPath:self.tempFolderPath error:nil];
}

#pragma mark Public

- (IBAction)onOptionsClick:(UIButton *)sender
{
    if(self.hiddenButtonsList.count > 0)
    {
        [self destroyHiddenButtonsOnBaseButton:(UIButton *)sender];
    }
    else
    {
        [self createHiddenButtons:sender];
    }
}

- (void)onListClick
{
    NSLog(@"List clicked");
}

- (void)onCameraClick
{
    [self showImagePicker];
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
    NSString *imagePath = [self.tempFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",[self getCurrentTime]]];
    
    [self saveImageInTempFolder:info imagePath:imagePath];
    [self insertImageAtEndOfWebview:imagePath];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(NSString*) getCurrentTime
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:TIME_DATE_FORMAT];
    return [dateFormatter stringFromDate:[NSDate date]];
}

-(void) saveImageInTempFolder:(NSDictionary*) imageInfo imagePath:(NSString*) imagePath
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
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSRange range = [noteBody rangeOfString:@"</div>"];
    [noteBody insertString:imageHtml atIndex:range.location];
    
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

- (void)onDrawingClick
{
    DrawingViewController *drawingViewController = [[DrawingViewController alloc] init];
    [self.navigationController pushViewController:drawingViewController animated:YES];
}

- (IBAction)onCreateClick:(id)sender
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
    
    [self displaySelectableMenuWithButton:sender list:array];
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
        Notebook *newNotebook = [[Notebook alloc] initWithName:textFromField];
        [self.manager addNotebook:newNotebook];
        [self notebookSelected:newNotebook];
    }]];
    
    return inputController;
}

- (void)notebookSelected:(Notebook*) noteBookSelected
{
    [self setNoteContent];
    [self.navigationController popViewControllerAnimated:YES];
    [self.manager addNote:self.note toNotebook:noteBookSelected];
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
    NSString *notePath = [[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                                    stringByAppendingPathComponent:NOTE_NOTEBOOKS_FOLDER]
                                    stringByAppendingPathComponent:self.currentNotebook]
                                    stringByAppendingPathComponent:self.note.name];
    
    NSString *stringForReplace = [self.tempFolderPath stringByAppendingString:@"/"];
    html = [html stringByReplacingOccurrencesOfString:stringForReplace withString:@""];
    
    stringForReplace = [notePath stringByAppendingString:@"/"];
    html = [html stringByReplacingOccurrencesOfString:stringForReplace withString:@""];
    
    return html;
}

- (IBAction)onSettingsSelected:(id)sender
{
    NSLog(@"Settings selected");
}

- (IBAction)onUnderlineSelected:(id)sender
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:JS_COMMAND_UNDERLINE];
}

- (IBAction)onItalicStyleSelected:(id)sender
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:JS_COMMAND_ITALIC];
}

- (IBAction)onBoldStyleSelected:(id)sender
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:JS_COMMAND_BOLD];
}

- (void)updateNoteFont:(NSString*) font
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:JS_COMMAND_FONT_TYPE, font]];
}

- (void)updateNoteSize:(NSString*) size
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:JS_COMMAND_FONT_SIZE, size]];
}

- (IBAction)onFontSelected:(id)sender
{
    NSMutableArray *array  = [[NSMutableArray alloc] init];
    
    for (NSString* currentItem in self.fontList)
    {
        [array addObject:[UIAlertAction actionWithTitle:currentItem style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                          {
                              [self performSelector:@selector(updateNoteFont:) withObject:currentItem];
                          }]];
    }
    
    [self displaySelectableMenuWithButton:sender list:array];
}

- (IBAction)onSizeSelected:(UIButton *)sender
{
    NSMutableArray *array  = [[NSMutableArray alloc] init];
    
    for (NSString* currentItem in self.textSizeList)
    {
        [array addObject:[UIAlertAction actionWithTitle:currentItem style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                          {
                              [self performSelector:@selector(updateNoteSize:) withObject:currentItem];
                          }]];
    }
    
    [self displaySelectableMenuWithButton:sender list:array];
}

#pragma mark Private

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

-(void) inflateTextSizeList
{
    [self.textSizeList addObject:@"10"];
    [self.textSizeList addObject:@"11"];
    [self.textSizeList addObject:@"12"];
    [self.textSizeList addObject:@"13"];
    [self.textSizeList addObject:@"14"];
}

-(void) inflateFontsList
{
    [self.fontList addObject:@"Times New Roman"];
    [self.fontList addObject:@"Arial"];
    [self.fontList addObject:@"Futura"];
    [self.fontList addObject:@"Verdana"];
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

- (void)createHiddenButtons:(UIButton *)sender
{
    long optionsButtonX = sender.frame.origin.x - SMALL_BUTTON_DISTANCE;
    long optionsButtonY = sender.frame.origin.y - SMALL_BUTTON_DISTANCE;
    [self createButtonWithX:optionsButtonX
                       andY:optionsButtonY
                 baseButton:sender
                buttonImage:[UIImage imageNamed:@"camera.png"]
                     action:@selector(onCameraClick)];
    
    optionsButtonX = sender.frame.origin.x - SMALL_BUTTON_DISTANCE;
    optionsButtonY = sender.frame.origin.y - 10;
    
    [self createButtonWithX:optionsButtonX
                       andY:optionsButtonY
                 baseButton:sender
                buttonImage:[UIImage imageNamed:@"drawing.png"]
                     action:@selector(onDrawingClick)];
    
    optionsButtonX = sender.frame.origin.x - 10;
    optionsButtonY = sender.frame.origin.y - SMALL_BUTTON_DISTANCE;
    [self createButtonWithX:optionsButtonX
                       andY:optionsButtonY
                 baseButton:sender
                buttonImage:[UIImage imageNamed:@"list.png"]
                     action:@selector(onListClick)];
}

- (void)createButtonWithX:(long)xCoordinates andY:(long)yCoordinates baseButton:(UIButton *)sender buttonImage:(UIImage *)image action:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 23;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.clipsToBounds = YES;
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];

    
    button.frame = CGRectMake(sender.frame.origin.x + SMALL_BUTTON_DISTANCE / 2,
                              sender.frame.origin.y + SMALL_BUTTON_DISTANCE / 2,
                              0,
                              0);
    
    [self.view addSubview:button];
    
    [UIView animateWithDuration:0.5
                     animations:^
    {
         button.frame = CGRectMake(xCoordinates, yCoordinates, SMALL_BUTTONS_WIDTH, SMALL_BUTTONS_HEIGHT);
    }
                     completion:^(BOOL finished)
    {
         [self.hiddenButtonsList addObject:button];
    }];
}

- (void)destroyHiddenButtonsOnBaseButton:(UIButton *)sender
{
    for (UIButton *button in self.hiddenButtonsList) {
        [UIView animateWithDuration:0.5
                         animations:^
         {
             button.frame = CGRectMake(sender.frame.origin.x + SMALL_BUTTON_DISTANCE / 2,
                                       sender.frame.origin.y + SMALL_BUTTON_DISTANCE / 2,
                                       0,
                                       0);
         }
                         completion:^(BOOL finished)
        {
            [button removeFromSuperview];
        }];
    }
    [self.hiddenButtonsList removeAllObjects];
}

@end
