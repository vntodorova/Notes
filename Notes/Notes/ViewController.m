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
    [sideDrawerButton addTarget:self action:@selector(drawerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [sideDrawerButton setBackgroundImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftNavigationBarButton = [[UIBarButtonItem alloc] initWithCustomView:sideDrawerButton];
    
    UIButton *addNoteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, NAVIGATION_BUTTONS_WIDTH, NAVIGATION_BUTTONS_HEIGHT)];
    [addNoteButton addTarget:self action:@selector(addButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [addNoteButton setBackgroundImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
    UIBarButtonItem *rightNavigationBarButton = [[UIBarButtonItem alloc] initWithCustomView:addNoteButton];

    self.navigationController.topViewController.navigationItem.leftBarButtonItem = leftNavigationBarButton;
    self.navigationController.topViewController.navigationItem.rightBarButtonItem = rightNavigationBarButton;
    self.navigationController.topViewController.navigationItem.titleView = [[UISearchBar alloc] init];
    
    leftNavigationBarButton.enabled = TRUE;
    rightNavigationBarButton.enabled = TRUE;
}

- (void)drawerButtonPressed
{
    
}

- (void)addButtonPressed
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
