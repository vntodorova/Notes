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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hiddenButtonsList = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

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
    [self createButtonWithX:optionsButtonX andY:optionsButtonY andBaseButton:sender andImage:[UIImage imageNamed:@"camera.png"]];
    
    optionsButtonX = sender.frame.origin.x - SMALL_BUTTON_DISTANCE;
    optionsButtonY = sender.frame.origin.y;
    [self createButtonWithX:optionsButtonX andY:optionsButtonY andBaseButton:sender andImage:[UIImage imageNamed:@"drawing.png"]];
    
    optionsButtonX = sender.frame.origin.x;
    optionsButtonY = sender.frame.origin.y - SMALL_BUTTON_DISTANCE;
    [self createButtonWithX:optionsButtonX andY:optionsButtonY andBaseButton:sender andImage:[UIImage imageNamed:@"list.png"]];
}

- (void)createButtonWithX:(long) xCoordinates andY:(long) yCoordinates andBaseButton:(UIButton *)sender andImage:(UIImage*)image
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(aMethod) forControlEvents:UIControlEventTouchUpInside];
    
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

- (void)aMethod{
    
}

- (IBAction)onCreateClick:(id)sender {
    self.note.name = self.noteName.text;
    self.note.tags = [self getTagsFromText:self.noteTags.text];
    self.note.body = self.noteBody.text;
}

- (NSArray *)getTagsFromText:(NSString *) tags
{
    return nil;
}

@end
