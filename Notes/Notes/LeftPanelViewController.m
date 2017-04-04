//
//  LeftPanelViewController.m
//  Notes
//
//  Created by Nemetschek A-Team on 4/3/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "LeftPanelViewController.h"
#import "Defines.h"

@interface LeftPanelViewController ()

@end

@implementation LeftPanelViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.isHidden = YES;
        self.view.frame = CGRectMake(-1 * LEFT_PANEL_WIDTH, 0, LEFT_PANEL_WIDTH, self.view.frame.size.height);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
