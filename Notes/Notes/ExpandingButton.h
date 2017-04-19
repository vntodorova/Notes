//
//  ExpandingButton.h
//  Notes
//
//  Created by VCS on 4/19/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpandingButton : UIButton

@property BOOL isExpanded;

- (instancetype)init;

- (void)showOptionsButtons;

- (void)hideOptionsButtons;

- (void)addSmallButton;

@end
