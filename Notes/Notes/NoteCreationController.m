//
//  NoteCreationController.m
//  Notes
//
//  Created by VCS on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "NoteCreationController.h"
#import "Defines.h"

@interface NoteCreationController ()

@property (nonatomic, strong) NSMutableArray *hiddenButtonsList;
@property (nonatomic, strong) NSMutableArray *fontList;
@property (nonatomic, strong) NSMutableArray *textSizeList;

@end

@implementation NoteCreationController

#pragma CONTROLLER

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hiddenButtonsList = [[NSMutableArray alloc] init];
    [self updateNoteFont:[UIFont systemFontOfSize:12]];
    
    [self inflateFontsList];
    [self inflateTextSizeList];
    
    self.noteBody.text = self.note.body;
    
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
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [self setNoteContent];
        [self.delegate onDraftCreated:self.note];
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
    NSLog(@"Drawing clicked");
}

- (IBAction)onCreateClick:(id)sender
{
    [self setNoteContent];
    [self.delegate onNoteCreated:self.note];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) setNoteContent
{
    self.note.name = self.noteName.text;
    self.note.tags = [self getTagsFromText:self.noteTags.text];
    self.note.body = self.noteBody.text;
    
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
    NSMutableAttributedString *strText = [[NSMutableAttributedString alloc] initWithAttributedString:self.noteBody.attributedText];
    
    [strText addAttribute:NSUnderlineStyleAttributeName
                    value:[NSNumber numberWithInt:NSUnderlineStyleSingle]
                    range:[self.noteBody selectedRange]];
    
    [self.noteBody setAttributedText:strText];
}

- (IBAction)onItalicStyleSelected:(id)sender
{
   [self setTextAtribute:UIFontDescriptorTraitItalic];
}

- (IBAction)onBoldStyleSelected:(id)sender
{
    [self setTextAtribute:UIFontDescriptorTraitBold];
}

- (void)updateNoteFont:(UIFont*)someFont
{
    
}

- (IBAction)onFontSelected:(id)sender
{
    [self inflateFontsList];
    [self displaySelectableMenuWithButton:sender list:self.fontList setter:@selector(updateNoteFont:)];
}

- (IBAction)onSizeSelected:(UIButton *)sender
{
    [self inflateTextSizeList];
    [self displaySelectableMenuWithButton:sender list:self.textSizeList setter:@selector(updateNoteFont:)];
}

#pragma PRIVATE

- (void)displaySelectableMenuWithButton:(UIButton *) button list:(NSMutableArray *)list setter:(SEL) updateSelector
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Categories"
                                                                   message:@"Choose category"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSString* currentItem in list)
    {
                        [alert addAction:[UIAlertAction actionWithTitle:currentItem style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                  {
                                      [self performSelector:updateSelector withObject:currentItem];
                                  }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
    popPresenter.sourceView = button;
    popPresenter.sourceRect = button.bounds;
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)setTextAtribute:(UIFontDescriptorSymbolicTraits) type
{
    UIFontDescriptor * fontD = [self.noteBody.font.fontDescriptor fontDescriptorWithSymbolicTraits: self.noteBody.font.fontDescriptor.symbolicTraits | type];
    NSMutableAttributedString *strText = [[NSMutableAttributedString alloc] initWithAttributedString:self.noteBody.attributedText];
    
    
    [strText addAttribute:NSFontAttributeName
                    value:[UIFont fontWithDescriptor:fontD size:0]
                    range:[self.noteBody selectedRange]];
    
    [self.noteBody setAttributedText:strText];
}

-(void) inflateTextSizeList
{
    self.textSizeList = [[NSMutableArray alloc] init];
    
    [self.textSizeList addObject:@"10"];
    [self.textSizeList addObject:@"11"];
    [self.textSizeList addObject:@"12"];
    [self.textSizeList addObject:@"13"];
    [self.textSizeList addObject:@"14"];
}

-(void) inflateFontsList
{
    self.fontList = [[NSMutableArray alloc] init];
    
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
    
    button.frame = CGRectMake(sender.frame.origin.x + SMALL_BUTTON_DISTANCE / 2,
                              sender.frame.origin.y + SMALL_BUTTON_DISTANCE / 2,
                              0,
                              0);
    
    [UIView animateWithDuration:0.5
                     animations:^
     {
         [button setImage:image forState:UIControlStateNormal];
         button.frame = CGRectMake(xCoordinates, yCoordinates, SMALL_BUTTONS_WIDTH, SMALL_BUTTONS_HEIGHT);
         [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
         [self.view addSubview:button];
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
                         completion:^(BOOL finished) {
                             [button removeFromSuperview];
                         }];
    }
    [self.hiddenButtonsList removeAllObjects];
}
@end
