//
//  GroupsTableViewController.m
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "GroupsTableViewController.h"

@interface GroupsTableViewController ()
@property (strong) NSArray *userGroups;
@end

@implementation GroupsTableViewController

- (void)refresh{
    [[PFUser currentUser] fetchInBackground];
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserGroup"];
    [query includeKey:@"group"];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [query whereKey:@"user" equalTo:currentUser];
        [query whereKey:@"accepted" equalTo:[NSNumber numberWithBool:YES]];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu UserGroups.", (unsigned long)objects.count);
                
                // Do something with the found objects
                self.userGroups = [objects mutableCopy];
                [self.tableView reloadData];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Fetch the devices from persistent data store
    [self refresh];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.userGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"userGroupCell";
    UITableViewCell *userGroupCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *userGroup = self.userGroups[indexPath.row];
    NSString *groupName = userGroup[@"group"][@"name"];
    NSNumber *balance = userGroup[@"balance"];
    
    if([balance longValue] >= 0){
        [userGroupCell.detailTextLabel setTextColor:[UIColor greenColor]];
    } else {
        [userGroupCell.detailTextLabel setTextColor:[UIColor redColor]];
    }
    
    [userGroupCell.textLabel setText:[NSString stringWithFormat:@"%@", groupName]];
    [userGroupCell.detailTextLabel setText:[balance stringValue]];
    
    PFFile *thumbnail = userGroup[@"group"][@"groupPic"];
    userGroupCell.imageView.image = [UIImage imageNamed:@"pill.png"];
    
    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        // Now that the data is fetched, update the cell's image property.
        if(!error) {
            userGroupCell.imageView.image = [UIImage imageWithData:data];
        } else {
            userGroupCell.imageView.image = [UIImage imageNamed:@"pill.png"];
        }
        
        userGroupCell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }];
    
    
    return userGroupCell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showGroup"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        GroupTabBarController *groupTabBarController = segue.destinationViewController;
        groupTabBarController.group = self.userGroups[indexPath.row][@"group"];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
