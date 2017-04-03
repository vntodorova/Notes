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
@property CGPoint pointerStartHoldCoordinates;

@end

@implementation TableViewCell

- (void)setupWithNote:(Note *)note
{
    self.nameLabel.text = note.name;
    self.infoLabel.text = note.dateCreated;
    self.cellNote = note;
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
    self.pointerStartHoldCoordinates = [longPress locationInView:self.tableView];
}

- (void)longPressChanged:(UILongPressGestureRecognizer *)longPress
{
    CGPoint location = [longPress locationInView:self.tableView];
    float currentPointerDistance = location.y - self.pointerStartHoldCoordinates.y;
    if(currentPointerDistance < ([self.tableView numberOfRowsInSection:0] * TABLEVIEW_CELL_HEIGHT))
    {
        CGPoint center = self.center;
        center.y = location.y;
        self.center = center;
    }
}

- (void)longPressEnded:(UILongPressGestureRecognizer *)longPress
{
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *currentIndexPath = [self.tableView indexPathForRowAtPoint:location];
    NSIndexPath *startingIndexPath = [self.tableView indexPathForRowAtPoint:self.pointerStartHoldCoordinates];
    NSInteger tableViewRows = [self.tableView numberOfRowsInSection:0];
    if (currentIndexPath && ![currentIndexPath isEqual:startingIndexPath] && currentIndexPath.row < tableViewRows) {
        [self.delegate exchangeObjectAtIndex:currentIndexPath.row withObjectAtIndex:startingIndexPath.row];
        [self.tableView moveRowAtIndexPath:startingIndexPath toIndexPath:currentIndexPath];
    }
    self.frame = CGRectMake(self.frame.origin.x,currentIndexPath.row*TABLEVIEW_CELL_HEIGHT, self.frame.size.width , self.frame.size.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
