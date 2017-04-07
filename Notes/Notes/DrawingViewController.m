//
//  DrawingViewController.m
//  Notes
//
//  Created by Nemetschek A-Team on 4/6/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "DrawingViewController.h"
#import "Defines.h"

@implementation DrawingViewController
{
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brushSize;
    CGFloat opacity;
    BOOL mouseSwiped;
    BOOL settingsHidden;
}

- (void)viewDidLoad {
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;

    [self.opacitySlider setValue:1.0];
    brushSize = self.sizeSlider.value*40;
    opacity = self.opacitySlider.value;
    [self hideOptionsPanel];
    settingsHidden = YES;
    
    [self.view bringSubviewToFront:self.mainImageView];
    [self.view bringSubviewToFront:self.opacityLabel];
    [self.view bringSubviewToFront:self.sizeLabel];
    [self.view bringSubviewToFront:self.sizeSlider];
    [self.view bringSubviewToFront:self.opacitySlider];
    [self.view bringSubviewToFront:self.tempImageView];
    
    [self setupToolbarButtons];
    [super viewDidLoad];
}

- (void)setupToolbarButtons
{
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    saveButton.frame = CGRectMake(0, 0, 40, BUTTONS_HEIGHT);
    UIBarButtonItem *saveToolbarButton = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIButton *settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTONS_WIDTH, BUTTONS_HEIGHT)];
    [settingsButton setBackgroundImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(settingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *settingsToolbarButton = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];

    
    UIButton *eraserButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTONS_WIDTH, BUTTONS_HEIGHT)];
    [eraserButton setBackgroundImage:[UIImage imageNamed:@"eraser.png"] forState:UIControlStateNormal];
    [eraserButton addTarget:self action:@selector(eraserButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *eraserToolbarButton = [[UIBarButtonItem alloc] initWithCustomView:eraserButton];
    
    UIButton *penButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTONS_WIDTH, BUTTONS_HEIGHT)];
    [penButton setBackgroundImage:[UIImage imageNamed:@"pen.png"] forState:UIControlStateNormal];
    [penButton addTarget:self action:@selector(penButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *penToolbarButton = [[UIBarButtonItem alloc] initWithCustomView:penButton];
    
    UIButton *colorButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTONS_WIDTH, BUTTONS_HEIGHT)];
    [colorButton setBackgroundImage:[UIImage imageNamed:@"colorPicker.png"] forState:UIControlStateNormal];
    [colorButton addTarget:self action:@selector(colorPickerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *colorToolbarButton = [[UIBarButtonItem alloc] initWithCustomView:colorButton];
    
    NSArray* buttonsArray = [NSArray arrayWithObjects: saveToolbarButton, flexibleSpace,settingsToolbarButton, eraserToolbarButton, penToolbarButton, colorToolbarButton, nil];
    
    [self setToolbarItems:buttonsArray];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)setBrushColor:(UIColor *)newColor
{
    [newColor getRed:&red green:&green blue:&blue alpha:&opacity];
}

#pragma mark -
#pragma mark Drawing methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!settingsHidden)
    {
        [self hideOptionsPanel];
        settingsHidden = YES;
    }
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.tempImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brushSize);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.tempImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.tempImageView setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if(!mouseSwiped) {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.tempImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brushSize);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.tempImageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContext(self.mainImageView.frame.size);
    [self.mainImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.tempImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempImageView.image = nil;
    UIGraphicsEndImageContext();
}

- (void)showOptionsPanel
{
    [self.sizeLabel setHidden:NO];
    [self.opacityLabel setHidden:NO];
    [self.opacitySlider setHidden:NO];
    [self.sizeSlider setHidden:NO];
}

- (void)hideOptionsPanel
{
    [self.sizeLabel setHidden:YES];
    [self.opacityLabel setHidden:YES];
    [self.opacitySlider setHidden:YES];
    [self.sizeSlider setHidden:YES];
}

#pragma mark -
#pragma mark Button methods

- (void)saveButtonPressed
{
    
}

- (void)settingsButtonPressed
{
    if(settingsHidden)
    {
        [self showOptionsPanel];
        settingsHidden = NO;
    } else if(!settingsHidden)
    {
        [self hideOptionsPanel];
        settingsHidden = YES;
    }
}

- (void)eraserButtonPressed
{
    [self setBrushColor:[UIColor whiteColor]];
    brushSize = 10.0;
}

- (void)penButtonPressed
{
    [self setBrushColor:[UIColor blackColor]];
    opacity = 1.0;
    brushSize = 10.0;
}

- (void)colorPickerButtonPressed
{
    
}

- (IBAction)sizeSliderChanged:(id)sender
{
    brushSize = self.sizeSlider.value*40;
}

- (IBAction)opacitySliderChanged:(id)sender
{
    opacity = self.opacitySlider.value;
}
@end
