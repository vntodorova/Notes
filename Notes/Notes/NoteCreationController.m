//
//  NoteCreationController.m
//  Notes
//
//  Created by VCS on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#import "NoteCreationController.h"

@interface NoteCreationController ()

@end

@implementation NoteCreationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onOptionsClick:(id)sender {
}

- (IBAction)onCreateClick:(id)sender {
    self.note.name = self.noteName.text;
    self.note.tags = [self getTagsFromText:self.noteTags.text];
    self.note.body = self.noteBody.text;
}

-(NSArray *) getTagsFromText:(NSString *) tags
{
    return nil;
}

@end
