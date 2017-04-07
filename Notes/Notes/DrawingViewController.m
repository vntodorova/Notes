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

- (void)viewDidLoad {
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    brush = 2.0;
    opacity = 1.0;
    
    [self setupToolbarButtons];
    [super viewDidLoad];
}

- (void)setupToolbarButtons
{
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    saveButton.frame = CGRectMake(0, 0, TOOLBAR_BUTTONS_WIDTH, TOOLBAR_BUTTONS_HEIGHT);
    UIBarButtonItem *saveToolbarButton = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIButton *eraserButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, TOOLBAR_BUTTONS_WIDTH, TOOLBAR_BUTTONS_HEIGHT)];
    [eraserButton setBackgroundImage:[UIImage imageNamed:@"eraser.png"] forState:UIControlStateNormal];
    [eraserButton addTarget:self action:@selector(eraserButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *eraserToolbarButton = [[UIBarButtonItem alloc] initWithCustomView:eraserButton];
    
    UIButton *penButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, TOOLBAR_BUTTONS_WIDTH, TOOLBAR_BUTTONS_HEIGHT)];
    [penButton setBackgroundImage:[UIImage imageNamed:@"pen.png"] forState:UIControlStateNormal];
    [penButton addTarget:self action:@selector(penButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *penToolbarButton = [[UIBarButtonItem alloc] initWithCustomView:penButton];
    
    UIButton *colorButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, TOOLBAR_BUTTONS_WIDTH, TOOLBAR_BUTTONS_HEIGHT)];
    [colorButton setBackgroundImage:[UIImage imageNamed:@"colorPicker.png"] forState:UIControlStateNormal];
    [colorButton addTarget:self action:@selector(colorPickerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *colorToolbarButton = [[UIBarButtonItem alloc] initWithCustomView:colorButton];
    
    NSArray* buttonsArray = [NSArray arrayWithObjects: saveToolbarButton, flexibleSpace, eraserToolbarButton, penToolbarButton, colorToolbarButton, nil];
    
    [self setToolbarItems:buttonsArray];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)saveButtonPressed
{
    
}

- (void)eraserButtonPressed
{
    
}

- (void)penButtonPressed
{
    
}

- (void)colorPickerButtonPressed
{
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.tempImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.tempImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.tempImageView setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(!mouseSwiped) {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.tempImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
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

@end
