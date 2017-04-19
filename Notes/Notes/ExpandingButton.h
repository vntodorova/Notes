//
//  ExpandingButton.h
//  Notes
//
//  Created by VCS on 4/19/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThemeManager;

@interface ExpandingButton : UIButton

@property BOOL isExpanded;

- (void)setup;

- (void)showOptionsButtons;

- (void)hideOptionsButtons;

- (void)addSmallButtonWithAction:(SEL)selector target:(id)target andImage:(NSString *)imageName;

@end
