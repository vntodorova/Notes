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

@interface NoteCreationController ()

@property (nonatomic, strong) NSMutableArray *hiddenButtonsList;
@property (nonatomic, strong) NSMutableArray *fontList;
@property (nonatomic, strong) NSMutableArray *textSizeList;
@property (nonatomic, strong) NSMutableArray *noteBookList;

@property (nonatomic, strong) LocalNoteManager *manager;
@end

@implementation NoteCreationController

#pragma CONTROLLER
-(instancetype)initWithManager:(LocalNoteManager *)manager
{
    self = [super self];
    self.manager = manager;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hiddenButtonsList = [[NSMutableArray alloc] init];
    self.fontList = [[NSMutableArray alloc] init];
    self.textSizeList = [[NSMutableArray alloc] init];
    
    [self inflateFontsList];
    [self inflateTextSizeList];

    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"emptyfile.html"];
    
    NSURL *indexFileURL = [[NSURL alloc] initWithString:filePath];
    
    [self.noteBody loadRequest:[NSURLRequest requestWithURL:indexFileURL]];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                     initWithTarget:self
                                             action:@selector(dismissKeyboard)]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self setNoteContent];
       // [self.delegate onDraftCreated:self.note];
    }
    [super viewWillDisappear:animated];
}

#pragma PUBLIC

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
    NSLog(@"Camera clicked");
}

- (void)onDrawingClick
{
    DrawingViewController *drawingViewController = [[DrawingViewController alloc] init];
    [self.navigationController pushViewController:drawingViewController animated:YES];
}

- (IBAction)onCreateClick:(id)sender
{
    NSMutableArray *array  = [[NSMutableArray alloc] init];
    for (Notebook* currentItem in [self.manager getNotebookList])
    {
        [array addObject:[UIAlertAction actionWithTitle:currentItem.name style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                          {
                              [self performSelector:@selector(notebookSelected:) withObject:currentItem];
                          }]];
    }
    
    [self displaySelectableMenuWithButton:sender list:array];
}

- (void)notebookSelected:(Notebook*) noteBookSelected
{
    [self setNoteContent];
    [self.navigationController popViewControllerAnimated:YES];
    [self saveNote];
    [self.manager addNote:self.note toNotebook:noteBookSelected];
}

-(void) setNoteContent
{
    self.note.name = self.noteName.text;
    self.note.tags = [self getTagsFromText:self.noteTags.text];
    self.note.body = [self.noteBody stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss, dd-MM-yyyy"];
    self.note.dateCreated = [dateFormatter stringFromDate:[NSDate date]];
}

- (IBAction)onSettingsSelected:(id)sender
{
    NSLog(@"Settings selected");
}

- (IBAction)onUnderlineSelected:(id)sender
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Underline\")"];
}

- (IBAction)onItalicStyleSelected:(id)sender
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Italic\")"];
}

- (IBAction)onBoldStyleSelected:(id)sender
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Bold\")"];
}

- (void)updateNoteFont:(NSString*) font
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontName', false, '%@')", font]];
}

- (void)updateNoteSize:(NSString*) size
{
    [self.noteBody stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontSize', false, '%@')", size]];
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

#pragma PRIVATE

- (void)displaySelectableMenuWithButton:(UIButton *) button list:(NSMutableArray*)nameList
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Categories"
                                                                   message:@"Choose category"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
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
    if([self.noteName isFirstResponder])
    {
        [self.noteName resignFirstResponder];
    }
    else if([self.noteTags isFirstResponder])
    {
        [self.noteTags resignFirstResponder];
    }
    else if([self.noteBody isFirstResponder])
    {
        [self.noteBody resignFirstResponder];
    }
}

- (NSArray *)getTagsFromText:(NSString *) tags
{
    return nil;
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
    optionsButtonY = sender.frame.origin.y;
    [self createButtonWithX:optionsButtonX
                       andY:optionsButtonY
                 baseButton:sender
                buttonImage:[UIImage imageNamed:@"drawing.png"]
                     action:@selector(onDrawingClick)];
    
    optionsButtonX = sender.frame.origin.x;
    optionsButtonY = sender.frame.origin.y - SMALL_BUTTON_DISTANCE;
    [self createButtonWithX:optionsButtonX
                       andY:optionsButtonY
                 baseButton:sender
                buttonImage:[UIImage imageNamed:@"list.png"]
                     action:@selector(onListClick)];
}

- (void)createButtonWithX:(long) xCoordinates andY:(long) yCoordinates baseButton:(UIButton *)sender buttonImage:(UIImage*)image action:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
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

-(void) saveNote
{
//    NSError *error;
//    NSString *stringToWrite = [self.noteBody stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
//    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"myfile.html"];
//    [stringToWrite writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}
@end
