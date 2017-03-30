//
//  ViewController.m
//  Notes
//
//  Created by Nemetschek A-Team on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "ViewController.h"
#import "Defines.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];

}

- (void)setupNavigationBar
{
    UIButton *sideDrawerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, NAVIGATION_BUTTONS_WIDTH, NAVIGATION_BUTTONS_HEIGHT)];
    [sideDrawerButton addTarget:self action:@selector(btnReloadPressed) forControlEvents:UIControlEventTouchUpInside];
    [sideDrawerButton setBackgroundImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftNavigationButton = [[UIBarButtonItem alloc] initWithCustomView:sideDrawerButton];
    
    self.navigationController.topViewController.navigationItem.leftBarButtonItem = leftNavigationButton;
    leftNavigationButton.enabled=TRUE;
}

- (void)btnReloadPressed
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
