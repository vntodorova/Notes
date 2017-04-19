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

@property (nonatomic, strong) UIButton *addImageButton;
@property (nonatomic, strong) UIButton *addDrawingButton;
@property (nonatomic, strong) UIButton *addListButton;

@end

@implementation ExpandingButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isExpanded = NO;
    }
    return self;
}

- (void)addSmallButton
{
    self.themeManager = [ThemeManager sharedInstance];
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
    
    self.addImageButton.frame = initialFrame;
    self.addDrawingButton.frame = initialFrame;
    self.addListButton.frame = initialFrame;
    
    [self.superview addSubview:self.addImageButton];
    [self.superview addSubview:self.addDrawingButton];
    [self.superview addSubview:self.addListButton];
    
    [UIView animateWithDuration:0.5
                     animations:^
     {
         self.addImageButton.frame = newImageButtonFrame;
         self.addDrawingButton.frame = newDrawingButtonFrame;
         self.addListButton.frame = newListButtonFrame;
     }];
    self.isExpanded = YES;
}

- (void)hideOptionsButtons
{
    CGRect newFrame = CGRectMake(self.frame.origin.x + SMALL_BUTTON_DISTANCE / 2, self.frame.origin.y + SMALL_BUTTON_DISTANCE / 2, 0, 0);
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
    self.isExpanded = NO;
}

@end
