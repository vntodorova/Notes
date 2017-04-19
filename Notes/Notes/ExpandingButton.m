//
//  ExpandingButton.m
//  Notes
//
//  Created by VCS on 4/19/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "ExpandingButton.h"
#import "Defines.h"
#import "ThemeManager.h"

@interface ExpandingButton()
@property (nonatomic, strong) ThemeManager *themeManager;
@property NSMutableArray<UIButton *> *buttons;
@end

@implementation ExpandingButton

- (void)setup
{
    [self setIsExpanded:NO];
    self.themeManager = [ThemeManager sharedInstance];
    self.buttons = [[NSMutableArray alloc] init];
}

- (void)addSmallButtonWithAction:(SEL)selector target:(id)target andImage:(NSString *)imageName
{
    CGFloat red, green, blue;
    [[self.themeManager.styles objectForKey:TINT] getRed:&red green:&green blue:&blue alpha:nil];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.layer.cornerRadius = 23;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor colorWithRed:red green:green blue:blue alpha:1].CGColor;
    button.clipsToBounds = YES;
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self.buttons addObject:button];
}

- (void)showOptionsButtons
{
    CGFloat optionsButtonFrameX = self.frame.origin.x;
    CGFloat optionsButtonFrameY = self.frame.origin.y;
    long optionsButtonX = optionsButtonFrameX - SMALL_BUTTON_DISTANCE;
    long optionsButtonY = optionsButtonFrameY - SMALL_BUTTON_DISTANCE;
    CGRect newImageButtonFrame = CGRectMake(optionsButtonX, optionsButtonY, SMALL_BUTTONS_WIDTH, SMALL_BUTTONS_HEIGHT);
    optionsButtonY = optionsButtonFrameY - 10;
    CGRect newDrawingButtonFrame = CGRectMake(optionsButtonX, optionsButtonY, SMALL_BUTTONS_WIDTH, SMALL_BUTTONS_HEIGHT);
    optionsButtonX = optionsButtonFrameX - 10;
    optionsButtonY = optionsButtonFrameY - SMALL_BUTTON_DISTANCE;
    CGRect newListButtonFrame = CGRectMake(optionsButtonX, optionsButtonY, SMALL_BUTTONS_WIDTH, SMALL_BUTTONS_HEIGHT);
    
    CGRect initialFrame = CGRectMake(optionsButtonFrameX + SMALL_BUTTON_DISTANCE / 2, optionsButtonFrameY + SMALL_BUTTON_DISTANCE / 2, 0, 0);
    
    for (UIButton *button in self.buttons)
    {
        [button setFrame:initialFrame];
        [self.superview addSubview:button];
    }
    
    [UIView animateWithDuration:0.5
                     animations:^
     {
         [[self.buttons objectAtIndex:0] setFrame:newImageButtonFrame];
         [[self.buttons objectAtIndex:1] setFrame:newDrawingButtonFrame];
         [[self.buttons objectAtIndex:2] setFrame:newListButtonFrame];
     }];
    self.isExpanded = YES;
}

- (void)hideOptionsButtons
{
    CGRect newFrame = CGRectMake(self.frame.origin.x + SMALL_BUTTON_DISTANCE / 2, self.frame.origin.y + SMALL_BUTTON_DISTANCE / 2, 0, 0);
    [UIView animateWithDuration:0.5
                     animations:^
     {
         for (UIButton *button in self.buttons)
         {
             [button setFrame:newFrame];
         }
     }
                     completion:^(BOOL finished)
     {
         for (UIButton *button in self.buttons)
         {
             [button removeFromSuperview];
         }
     }];
    self.isExpanded = NO;
}

@end
