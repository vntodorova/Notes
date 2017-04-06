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

- (void)panGestureRecognisedOnCell:(TableViewCell *)cell;
- (void)exchangeObjectAtIndex:(NSInteger)firstIndex withObjectAtIndex:(NSInteger)secondIndex;

@end

@protocol LeftPanelDelegate

- (void)hideLeftPanel;

@end

#endif /* PublicProtocols_h */