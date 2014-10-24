//
//  BalanceManagementTableViewController.m
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "BalanceManagementTableViewController.h"
#import "SWRevealViewController.h"

@interface BalanceManagementTableViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@end

@implementation BalanceManagementTableViewController
GroupTabBarController *groupTabBarController;
NSUInteger indexOfLowestBalance;
double lowestBalance = 0.0;

- (void)refresh{
    //Retrieving GroupUser list
    PFQuery *groupUsersQuery = [PFQuery queryWithClassName:@"UserGroup"];
    [groupUsersQuery includeKey:@"user"];
    [groupUsersQuery whereKey:@"group" equalTo:groupTabBarController.group];
    [groupUsersQuery whereKey:@"accepted" equalTo:[NSNumber numberWithBool:YES]];
    [groupUsersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu UserGroups.", (unsigned long)objects.count);
            
            // Do something with the found objects
            groupTabBarController.groupUsers = [objects mutableCopy];
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    self.navigationItem.title = groupTabBarController.group[@"name"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    groupTabBarController =(GroupTabBarController*)[(BalanceNavigationController *)[self navigationController] parentViewController];
    [self refresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Fetch the devices from persistent data store
    [self.tableView reloadData];
    self.navigationItem.title = groupTabBarController.group[@"name"];
    
    [groupTabBarController.groupUsers enumerateObjectsUsingBlock:^(PFObject *groupUser, NSUInteger idx, BOOL *stop) {
        if([groupUser[@"balance"] doubleValue] < lowestBalance){
            lowestBalance = [groupUser[@"balance"] doubleValue];
            indexOfLowestBalance = idx;
        };
    }];
    if(lowestBalance != 0.0){
    UITableViewCell *tableViewCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfLowestBalance inSection:0]];
    [tableViewCell.contentView.layer setBorderColor:[UIColor redColor].CGColor];
    [tableViewCell.contentView.layer setBorderWidth:2.0f];
    lowestBalance = 0.0;
    }
    
}

- (void)viewDidDisappear:(BOOL)animated{
    UITableViewCell *tableViewCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfLowestBalance inSection:0]];
    [tableViewCell.contentView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [tableViewCell.contentView.layer setBorderWidth:0.0f];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return groupTabBarController.groupUsers.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)groupUserTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"groupUserCell";
    UITableViewCell *groupUserCell = [groupUserTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *groupUser = groupTabBarController.groupUsers[indexPath.row];
    NSString *userName = groupUser[@"user"][@"name"];
    NSNumber *balance = groupUser[@"balance"];
    
    if([balance longValue] >= 0){
        [groupUserCell.detailTextLabel setTextColor:[UIColor greenColor]];
    } else {
        [groupUserCell.detailTextLabel setTextColor:[UIColor redColor]];
    }
    
    [groupUserCell.textLabel setText:[NSString stringWithFormat:@"%@", userName]];
    [groupUserCell.detailTextLabel setText:[balance stringValue]];
    groupUserCell.imageView.image = [UIImage imageNamed:@"images.jpeg"];
    
    return groupUserCell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addNewExpenseSegue"]) {
        NewExpenseNavigationController *destNavigationController = segue.destinationViewController;
        destNavigationController.groupUsers = groupTabBarController.groupUsers;
        destNavigationController.group = groupTabBarController.group;
        
        [destNavigationController setDelegate:self];
    }
    if ([segue.identifier isEqualToString:@"showUserExpenses"]) {
        UserExpenseHistoryTableViewController *destViewController = (UserExpenseHistoryTableViewController *)[(UINavigationController *)segue.destinationViewController topViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        destViewController.groupUser = groupTabBarController.groupUsers[indexPath.row];
        destViewController.group = groupTabBarController.group;
        destViewController.groupUsers = groupTabBarController.groupUsers;
    }
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
