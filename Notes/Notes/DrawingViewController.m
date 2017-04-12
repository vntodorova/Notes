//
//  DrawingViewController.m
//  Notes
//
//  Created by Nemetschek A-Team on 4/6/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "DrawingViewController.h"
#import "Defines.h"
#import "LayoutProvider.h"

@interface DrawingViewController()
@property UIVisualEffectView *bluredView;
@property BOOL statusBarHidden;
@property LayoutProvider *layoutProvider;
@end

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

    [self setupBlurredView];
    [self hideSettingsPanel];

    self.layoutProvider = [LayoutProvider sharedInstance];
    
    [self.opacitySlider setValue:1.0];
    brushSize = self.sizeSlider.value*40;
    opacity = self.opacitySlider.value;
    [self.settingsPanel setHidden:YES];
    settingsHidden = YES;
    
    [self.view bringSubviewToFront:self.bluredView];
    [self.view bringSubviewToFront:self.settingsPanel];
    
    [self setupToolbarButtons];
    [super viewDidLoad];
}

- (void)setupBlurredView
{
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    self.bluredView = [[UIVisualEffectView alloc] initWithEffect:effect];
    [self.bluredView.layer setCornerRadius:30.0f];
    self.bluredView.layer.masksToBounds = YES;
    self.bluredView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.bluredView setHidden:YES];
    [self.view addSubview:self.bluredView];
}

- (void)setupToolbarButtons
{
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    saveButton.frame = CGRectMake(0, 0, 40, BUTTONS_HEIGHT);
    UIBarButtonItem *saveToolbarButton = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    
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
    
    NSArray *leftButtonsArray = [NSArray arrayWithObjects:saveToolbarButton, settingsToolbarButton, eraserToolbarButton, penToolbarButton, colorToolbarButton, nil];
    
    self.navigationItem.rightBarButtonItems = leftButtonsArray;
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
        [self hideSettingsPanel];
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

- (void)showSettingsPanel
{
    self.bluredView.frame = CGRectMake(self.settingsPanel.frame.origin.x, self.settingsPanel.frame.origin.y, self.settingsPanel.frame.size.width, self.settingsPanel.frame.size.height + 20);
    [self.bluredView setHidden:NO];
    [self.settingsPanel setHidden:NO];
    [UIView animateWithDuration:0.5 animations:^{
        [self.bluredView setAlpha:1];
        [self.settingsPanel setAlpha:1];
    }];
}

- (void)hideSettingsPanel
{
    [UIView animateWithDuration:0.5 animations:^{
        [self.bluredView setAlpha:0];
        [self.settingsPanel setAlpha:0];
    } completion:^(BOOL finished) {
        [self.settingsPanel setHidden:YES];
        [self.bluredView setHidden:YES];
    }];
}

#pragma mark -
#pragma mark Button methods

- (void)discardButtonPressed
{
    
}

- (void)saveButtonPressed
{
    
}

- (void)settingsButtonPressed
{
    if(settingsHidden)
    {
        [self showSettingsPanel];
        settingsHidden = NO;
    } else if(!settingsHidden)
    {
        [self hideSettingsPanel];
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Pick a color" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* blackColor = [UIAlertAction actionWithTitle:@"Black" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setBrushColor:[UIColor blackColor]];
    }];
    [alertController addAction:blackColor];
        
    UIAlertAction* redColor = [UIAlertAction actionWithTitle:@"Red" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self setBrushColor:[UIColor redColor]];
             }];
    [alertController addAction:redColor];
    
    UIAlertAction* blueColor= [UIAlertAction actionWithTitle:@"Blue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setBrushColor:[UIColor blueColor]];
    }];
    [alertController addAction:blueColor];
    
    UIAlertAction* cyanColor= [UIAlertAction actionWithTitle:@"Cyan" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setBrushColor:[UIColor cyanColor]];
    }];
    [alertController addAction:cyanColor];
    
    UIAlertAction* greenColor= [UIAlertAction actionWithTitle:@"Green" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setBrushColor:[UIColor greenColor]];
    }];
    [alertController addAction:greenColor];
    
    UIAlertAction* orangeColor= [UIAlertAction actionWithTitle:@"Orange" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setBrushColor:[UIColor orangeColor]];
    }];
    [alertController addAction:orangeColor];
    
    UIAlertAction* purpleColor= [UIAlertAction actionWithTitle:@"Purple" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setBrushColor:[UIColor purpleColor]];
    }];
    [alertController addAction:purpleColor];
    
    UIAlertAction* magentaColor= [UIAlertAction actionWithTitle:@"Magenta" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setBrushColor:[UIColor magentaColor]];
    }];
    [alertController addAction:magentaColor];
    
    UIAlertAction* yellowColor= [UIAlertAction actionWithTitle:@"Yellow" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setBrushColor:[UIColor yellowColor]];
    }];
    [alertController addAction:yellowColor];
    
    [self presentViewController:alertController animated:YES completion:nil];
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
