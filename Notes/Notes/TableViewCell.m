//
//  TableViewCell.m
//  Notes
//
//  Created by Nemetschek A-Team on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "TableViewCell.h"
#import "Defines.h"

@implementation TableViewCell

- (void)setupWithNote:(Note *)note
{
    self.nameLabel.text = note.name;
    self.infoLabel.text = note.dateCreated;
    self.cellNote = note;
    self.layer.cornerRadius = 5;
    self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 2.0f);
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOpacity = 1.0f;
    self.layer.masksToBounds = NO;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIPanGestureRecognizer *recogniser = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    [self addGestureRecognizer:recogniser];
    recogniser.delegate = self;
}

- (void)swiped:(UIPanGestureRecognizer *)swipe
{
    if(swipe.state == UIGestureRecognizerStateBegan)
    {
        [self swipeBegan:swipe];
    }
    if(swipe.state == UIGestureRecognizerStateChanged)
    {
        [self swipeChanged:swipe];
    }
    if(swipe.state == UIGestureRecognizerStateEnded)
    {
        [self swipeEnded:swipe];
    }
}

- (void)swipeBegan:(UIPanGestureRecognizer *)swipe
{
    self.pointerStartDragCoordinatesX = [swipe locationInView:self.window].x;
    self.cellStartDragCoordinatesX = self.frame.origin.x;
}

- (void)swipeChanged:(UIPanGestureRecognizer *)swipe
{
    float currentPointerDistance = [swipe locationInView:self.window].x - self.pointerStartDragCoordinatesX;
    CGFloat offSet = self.cellStartDragCoordinatesX + currentPointerDistance;
    self.frame = CGRectMake(offSet,self.frame.origin.y, self.frame.size.width , self.frame.size.height);
}

- (void)swipeEnded:(UIPanGestureRecognizer *)swipe
{
    if(self.frame.origin.x > CELL_DRAG_ACTIVATION_DISTANCE)
    {
        [self.delegate swipedCell:swipe onCell:self];
    }
    else
    {
        [UIView animateWithDuration:0.8 animations:^
         {
             self.frame = CGRectMake(self.cellStartDragCoordinatesX,self.frame.origin.y, self.frame.size.width , self.frame.size.height);
         }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
