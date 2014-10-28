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
        NSLog(@"Unhandled editing style! %d", editingStyle);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"memberCell";
//    UITableViewCell *memberCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    UITableViewCell *memberCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if (memberCell == nil) {
        memberCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSString *name =[NSString stringWithFormat:@"%@", self.groupUsers[indexPath.row][@"user"][@"name"]];
    [memberCell.textLabel setText:name];
    
    PFFile *thumbnail = self.groupUsers[indexPath.row][@"user"][@"profilePic"];
    memberCell.imageView.image = [UIImage imageNamed:@"pill.png"];
    
    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        // Now that the data is fetched, update the cell's image property.
        if(!error) {
            memberCell.imageView.image = [UIImage imageWithData:data];
        } else {
            memberCell.imageView.image = [UIImage imageNamed:@"pill.png"];
        }
        
        memberCell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }];
    return memberCell;
}

@end
