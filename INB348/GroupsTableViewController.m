//
//  GroupsTableViewController.m
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "GroupsTableViewController.h"

@interface GroupsTableViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@property (strong) NSArray *userGroups;
@end

@implementation GroupsTableViewController

- (void)refresh{
    PFQuery *query = [PFQuery queryWithClassName:@"UserGroup"];
    [query includeKey:@"group"];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [query whereKey:@"user" equalTo:currentUser];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %d UserGroups.", objects.count);
                
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
    [self customSetup];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    [userGroupCell.textLabel setText:[NSString stringWithFormat:@"%@", groupName]];
    [userGroupCell.detailTextLabel setText:[balance stringValue]];
    userGroupCell.imageView.image = [UIImage imageNamed:@"images.jpeg"];
    
    return userGroupCell;
}

- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.revealButtonItem setTarget: revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showGroup"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        GroupTabBarController *groupTabBarController = segue.destinationViewController;
        groupTabBarController.group = self.userGroups[indexPath.row][@"group"];
    }
    
//    if ([segue.identifier isEqualToString:@"newGroup"]) {
//        NewGroupViewController *destViewController = (NewGroupViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
//        [destViewController setDelegate:self];
//    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
