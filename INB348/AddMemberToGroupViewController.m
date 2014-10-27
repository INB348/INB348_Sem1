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
        PFObject *newGroupUser = [PFObject objectWithClassName:@"UserGroup"];
        [newGroupUser setObject:self.group forKey:@"group"];
        [newGroupUser setObject:user forKey:@"user"];
        [newGroupUser setValue:[NSNumber numberWithBool:NO] forKey:@"accepted"];
        [newGroupUser setValue:@0 forKey:@"balance"];
        [newGroupUser saveEventually];
        
        
        // Send invite message notification
        PFQuery *query = [PFQuery queryWithClassName:@"Group"];
        [query getObjectInBackgroundWithId:self.group.objectId block:^(PFObject *gName, NSError *error) {
            
            NSString *string1 = [[PFUser currentUser] objectForKey:@"name"];
            NSString *string2 = gName[@"name"];
            NSString *note = [NSString stringWithFormat: @"'%@' invited you to join '%@'", string1, string2];
            
            PFObject *addMemberNotification = [PFObject objectWithClassName:@"Notifications"];
            [addMemberNotification setObject:[PFUser currentUser] forKey:@"fromUser"];
            [addMemberNotification setObject:user forKey:@"toUser"];
            [addMemberNotification setObject:note forKey:@"note"];
            [addMemberNotification setValue:[NSNumber numberWithBool:NO] forKey:@"read"];
            [addMemberNotification saveEventually];
        }];
        
        
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } else{
        NSLog(@"User doesn't exist");
    }
}
@end
