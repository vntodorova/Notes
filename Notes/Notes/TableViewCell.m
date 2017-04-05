//
//  TableViewCell.m
//  Notes
//
//  Created by Nemetschek A-Team on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "TableViewCell.h"
#import "Defines.h"

@interface TableViewCell()
@property float pointerStartPanCoordinatesX;
@property float cellStartPanCoordinatesX;
@property NSIndexPath *sourceIndexPath;
@property UIView *snapshot;
@end

@implementation TableViewCell

- (void)setupWithNote:(Note *)note
{
    self.nameLabel.text = note.name;
    self.infoLabel.text = note.dateCreated;
    self.cellNote = note;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIPanGestureRecognizer *panRecogniser = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognised:)];
    [self addGestureRecognizer:panRecogniser];
    panRecogniser.delegate = self;
    UILongPressGestureRecognizer *longPressRecogniser = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognised:)];
    [self addGestureRecognizer:longPressRecogniser];
    longPressRecogniser.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)createCellSnapshot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.snapshot = [[UIImageView alloc] initWithImage:image];
}

#pragma mark -
#pragma mark Pan gesture recogniser

- (void)panGestureRecognised:(UIPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [self panBegan:pan];
            break;
        case UIGestureRecognizerStateChanged:
            [self panChanged:pan];
            break;
        case UIGestureRecognizerStateEnded:
            [self panEnded:pan];
            break;
        default:
            break;
    }
}

- (void)panBegan:(UIPanGestureRecognizer *)pan
{
    self.pointerStartPanCoordinatesX = [pan locationInView:self.window].x;
    self.cellStartPanCoordinatesX = self.frame.origin.x;
}

- (void)panChanged:(UIPanGestureRecognizer *)pan
{
    float currentPointerDistance = [pan locationInView:self.window].x - self.pointerStartPanCoordinatesX;
    if(currentPointerDistance >= 0)
    {
        CGFloat offSet = self.cellStartPanCoordinatesX + currentPointerDistance;
        self.frame = CGRectMake(offSet,self.frame.origin.y, self.frame.size.width , self.frame.size.height);
    }
}

- (void)panEnded:(UIPanGestureRecognizer *)pan
{
    if(self.frame.origin.x > CELL_DRAG_ACTIVATION_DISTANCE)
    {
        [self.delegate panGestureRecognisedOnCell:self];
    }
    else
    {
        [UIView animateWithDuration:0.8 animations:^
         {
             self.frame = CGRectMake(self.cellStartPanCoordinatesX,self.frame.origin.y, self.frame.size.width , self.frame.size.height);
         }];
    }
}

#pragma mark -
#pragma mark Long press gesture recogniser

- (void)longPressGestureRecognised:(UILongPressGestureRecognizer *)longPress
{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
            [self longPressBegan:longPress];
            break;
        case UIGestureRecognizerStateChanged:
            [self longPressChanged:longPress];
            break;
        case UIGestureRecognizerStateEnded:
            [self longPressEnded:longPress];
            break;
        default:
            break;
    }
}

- (void)longPressBegan:(UILongPressGestureRecognizer *)longPress
{
    CGPoint location = [longPress locationInView:self.tableView];
    self.sourceIndexPath = [self.tableView indexPathForRowAtPoint:location];
    [self createCellSnapshot];
    self.snapshot.center = self.center;
    self.snapshot.alpha = 0.0;
    [self.tableView addSubview:self.snapshot];
    [UIView animateWithDuration:0.25 animations:^{
        self.snapshot.center = CGPointMake(self.center.x, location.y);
        self.snapshot.alpha = 1;
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (void)longPressChanged:(UILongPressGestureRecognizer *)longPress
{
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    self.snapshot.center = CGPointMake(self.center.x, location.y);
    if (indexPath && ![indexPath isEqual:self.sourceIndexPath]) {
        [self.delegate exchangeObjectAtIndex:indexPath.row withObjectAtIndex:self.sourceIndexPath.row];
        [self.tableView moveRowAtIndexPath:self.sourceIndexPath toIndexPath:indexPath];
        self.sourceIndexPath = indexPath;
    }}

- (void)longPressEnded:(UILongPressGestureRecognizer *)longPress
{
    self.hidden = NO;
    self.alpha = 0.0;
    [UIView animateWithDuration:0.25 animations:^{
        self.snapshot.center = self.center;
        self.snapshot.alpha = 0.0;
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.sourceIndexPath = nil;
        [self.snapshot removeFromSuperview];
        self.snapshot = nil;
    }];
}

@end
