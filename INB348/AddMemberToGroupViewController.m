//
//  AddMemberToGroupViewController.m
//  INB348
//
//  Created by Kristian M Matzen on 10/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "AddMemberToGroupViewController.h"

@interface AddMemberToGroupViewController ()

@end

@implementation AddMemberToGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)add:(id)sender {
    NSLog(@"Attempting to add member");
    for (PFObject *groupUser in self.groupUsers) {
        if([groupUser[@"user"][@"username"] isEqualToString:self.usernameLabel.text]){
            NSLog(@"User is already a part of the group");
            return;
        }
    }
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:self.usernameLabel.text];
    PFUser *user = (PFUser *)[query getFirstObject];
    if(user != nil){
        NSLog(@"User exists - Sending request");
        [self dismissViewControllerAnimated:YES completion:nil];
    } else{
        NSLog(@"User doesn't exist");
    }
}
@end
