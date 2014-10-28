//
//  GroupsTableViewController.m
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "GroupsTableViewController.h"
#import "ColorSingleton.h"

@interface GroupsTableViewController ()
@property (strong) NSArray *userGroups;
@end

@implementation GroupsTableViewController
ColorSingleton *colorSingleton;

- (void)refresh{
    [[PFUser currentUser] fetchInBackground];
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserGroup"];
    [query includeKey:@"group"];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [query whereKey:@"user" equalTo:currentUser];
        [query whereKey:@"accepted" equalTo:[NSNumber numberWithBool:YES]];
        [query orderByDescending:@"updatedAt"];
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
    colorSingleton = [ColorSingleton sharedColorSingleton];
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

- (void)setUserName:(PFObject *)groupUser groupUserCell:(UITableViewCell *)groupUserCell
{
    NSString *groupName = groupUser[@"group"][@"name"];
    [groupUserCell.textLabel setText:groupName];
}

- (void)setBalance:(PFObject *)userGroup fmt:(NSNumberFormatter *)fmt userGroupCell:(UITableViewCell *)userGroupCell
{
    NSNumber *balance = userGroup[@"balance"];
    [userGroupCell.detailTextLabel setText:[fmt stringFromNumber:balance]];
    if([balance longValue] >= 0){
        [userGroupCell.detailTextLabel setTextColor:[colorSingleton getGreenColor]];
    } else {
        [userGroupCell.detailTextLabel setTextColor:[colorSingleton getRedColor]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"userGroupCell";
    UITableViewCell *userGroupCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *userGroup = self.userGroups[indexPath.row];
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.##"];
    
    [self setUserName:userGroup groupUserCell:userGroupCell];
    [self setBalance:userGroup fmt:fmt userGroupCell:userGroupCell];
    
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
