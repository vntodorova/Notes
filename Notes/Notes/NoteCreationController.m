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
@property NSMutableArray *hiddenButtonsList;

@end

@implementation NoteCreationController

#pragma CONTROLLER

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hiddenButtonsList = [[NSMutableArray alloc] init];
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
}

-(void) setNoteContent
{
    self.note.name = self.noteName.text;
    self.note.tags = [self getTagsFromText:self.noteTags.text];
    self.note.body = self.noteBody.text;
}

- (NSArray *)getTagsFromText:(NSString *) tags
{
    return nil;
}

- (IBAction)onSettingsSelected:(id)sender
{
    NSLog(@"Settings selected");
}

- (IBAction)onUnderlineSelected:(id)sender
{
     NSLog(@"Underline selected");
}

- (IBAction)onItalicStyleSelected:(id)sender
{
     NSLog(@"Italic selected");
}

- (IBAction)onBoldStyleSelected:(id)sender
{
     NSLog(@"Bold selected");
}

- (IBAction)onFontSelected:(id)sender
{
     NSLog(@"Font selected");
}

@end
