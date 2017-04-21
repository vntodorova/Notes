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
    UIColor *lastBrushColor;
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
    UIBarButtonItem *saveToolbarButton = [self.layoutProvider saveBarButtonWithAction:@selector(saveButtonPressed) target:self];
    UIBarButtonItem *settingsToolbarButton = [self.layoutProvider settingsBarButtonWithAction:@selector(settingsButtonPressed) target:self];
    UIBarButtonItem *eraserToolbarButton = [self.layoutProvider eraserBarButtonWithAction:@selector(eraserButtonPressed) target:self];
    UIBarButtonItem *penToolbarButton = [self.layoutProvider penBarButtonWithAction:@selector(penButtonPressed) target:self];
    UIBarButtonItem *colorToolbarButton = [self.layoutProvider colorPickerBarButtonWithAction:@selector(colorPickerButtonPressed) target:self];
    NSArray *leftButtonsArray = [NSArray arrayWithObjects:saveToolbarButton, settingsToolbarButton, eraserToolbarButton, penToolbarButton, colorToolbarButton, nil];
    self.navigationItem.rightBarButtonItems = leftButtonsArray;
}

- (void)setBrushColor:(UIColor *)newColor
{
    [newColor getRed:&red green:&green blue:&blue alpha:&opacity];
    if(newColor != [UIColor whiteColor])
    {
        lastBrushColor = newColor;
    }
}

- (UIImage *)imageOfScreen
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(nil, screenSize.width, screenSize.height, 8, 4*(int)screenSize.width, colorSpaceRef, kCGImageAlphaPremultipliedLast);
    CGContextTranslateCTM(ctx, 0.0, screenSize.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    [(CALayer*)self.view.layer renderInContext:ctx];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGContextRelease(ctx);
    return image;
}

#pragma mark -
#pragma mark Drawing methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!settingsHidden)
    {
        [self hideSettingsPanel];
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
    } completion:^(BOOL finished) {
        settingsHidden = NO;
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
        settingsHidden = YES;
    }];
}

#pragma mark -
#pragma mark Button methods

- (void)saveButtonPressed
{
    [self.delegate drawingSavedAsImage:[self imageOfScreen]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)settingsButtonPressed
{
    if(settingsHidden)
    {
        [self showSettingsPanel];
    }
    else
    {
        [self hideSettingsPanel];
    }
}

- (void)eraserButtonPressed
{
    [self setBrushColor:[UIColor whiteColor]];
}

- (void)penButtonPressed
{
    [self setBrushColor:lastBrushColor];
}

- (void)colorPickerButtonPressed
{
    NSArray *colorNames = [NSArray arrayWithObjects:@"Black", @"Red", @"Blue", @"Cyan", @"Green", @"Orange", @"Purple", @"Magenta", @"Yellow", nil];
    NSArray *colors = [NSArray arrayWithObjects:[UIColor blackColor], [UIColor redColor], [UIColor blueColor], [UIColor cyanColor], [UIColor greenColor], [UIColor orangeColor], [UIColor purpleColor], [UIColor magentaColor], [UIColor yellowColor], nil];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Pick a color" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSInteger i = 0; i < colorNames.count ; i++) {
        UIAlertAction* action = [UIAlertAction actionWithTitle:[colorNames objectAtIndex:i] style:UIAlertActionStyleDefault handler:^
                                 (UIAlertAction * _Nonnull action) {
                                     [self setBrushColor:[colors objectAtIndex:i]];
                                 }];
        [alertController addAction:action];
    }
    
    alertController.popoverPresentationController.sourceView = self.view;
    UIBarButtonItem *item = [self.navigationItem.rightBarButtonItems lastObject];
    CGRect itemFrame = [[item valueForKey:@"view"] frame];
    alertController.popoverPresentationController.sourceRect = CGRectMake(itemFrame.origin.x, itemFrame.origin.y + 20, itemFrame.size.width, itemFrame.size.height);
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
