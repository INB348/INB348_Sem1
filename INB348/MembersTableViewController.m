//
//  MembersTableViewController.m
//  INB348
//
//  Created by Kristian M Matzen on 10/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "MembersTableViewController.h"

@interface MembersTableViewController ()

@end

@implementation MembersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.groupUsers.count;
}

- (BOOL)isBalanceZero{
    for (PFObject *groupUser in self.groupUsers) {
        if(![groupUser[@"balance"] isEqualToNumber:@0]){
            return false;
        }
    }
    return true;
}

- (void)reloadGroupUsers{
    //Retrieving GroupUser list
    PFQuery *groupUsersQuery = [PFQuery queryWithClassName:@"UserGroup"];
    [groupUsersQuery includeKey:@"user"];
    [groupUsersQuery whereKey:@"group" equalTo:self.group];
    [groupUsersQuery whereKey:@"accepted" equalTo:[NSNumber numberWithBool:YES]];
    [groupUsersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu UserGroups.", (unsigned long)objects.count);
            
            // Do something with the found objects
            self.groupUsers = [objects mutableCopy];
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //[groupTabBarController.groupUsers removeObjectAtIndex:indexPath.row];
        //[self.membersTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        PFObject *groupUser = self.groupUsers[indexPath.row];
        if([groupUser[@"balance"] isEqualToNumber:@0]){
            [groupUser deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    PFUser *user = groupUser[@"user"];
                    if ([user.objectId isEqualToString:[PFUser currentUser].objectId]) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    [self reloadGroupUsers];
                }
            }];
        } else{
            NSLog(@"%@ needs to have a balance of 0 before deletion",groupUser[@"user"][@"name"]);
        }
    } else {
        NSLog(@"Unhandled editing style! %ld", editingStyle);
    }
}

- (UITableViewCell *)tableView:(UITableView *)groupUserTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"memberCell";
    UITableViewCell *memberCell = [groupUserTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *name =[NSString stringWithFormat:@"%@", self.groupUsers[indexPath.row][@"user"][@"name"]];
    [memberCell.textLabel setText:name];
    
    return memberCell;
}

@end
