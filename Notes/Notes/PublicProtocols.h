//
//  PublicProtocols.h
//  Notes
//
//  Created by Nemetschek A-Team on 3/31/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#ifndef PublicProtocols_h
#define PublicProtocols_h

@class TableViewCell;

@protocol TableViewCellDelegate

- (void)swipedCell:(UIPanGestureRecognizer *)drag onCell:(TableViewCell *)cell;

@end

#endif /* PublicProtocols_h */
