//
//  LayoutProvider.m
//  Notes
//
//  Created by Nemetschek A-Team on 3/31/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "LayoutProvider.h"
#import "Defines.h"

@implementation LayoutProvider

- (TableViewCell *)getNewCell:(UITableView *)tableView withNote:(Note *)note
{
    TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:TABLEVIEW_CELL_ID];
    [cell setupWithNote:note];
    return cell;
}

- (UIBarButtonItem *)setupLeftBarButton:(id)target withSelector:(SEL)selector;
{
    UIButton *leftBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, NAVIGATION_BUTTONS_WIDTH, NAVIGATION_BUTTONS_HEIGHT)];
    [leftBarButton setBackgroundImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
    [leftBarButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
}

- (UIBarButtonItem *)setupRightBarButton:(id)target withSelector:(SEL)selector;
{
    UIButton *rightBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, NAVIGATION_BUTTONS_WIDTH, NAVIGATION_BUTTONS_HEIGHT)];
    [rightBarButton setBackgroundImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
    [rightBarButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
}

@end
