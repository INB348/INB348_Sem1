//
//  BalanceManagementTableViewController.m
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "BalanceManagementTableViewController.h"
#import "SWRevealViewController.h"
#import "ColorSingleton.h"
#import "NumberFormatterSingleton.h"

@interface BalanceManagementTableViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@end

@implementation BalanceManagementTableViewController
GroupTabBarController *groupTabBarController;
NSUInteger indexOfLowestBalance;
double lowestBalance = 0.0;
ColorSingleton *colorSingleton;
NumberFormatterSingleton *numberFormatterSingleton;

#pragma mark - Setup
- (void)viewDidLoad
{
    [super viewDidLoad];
    groupTabBarController =(GroupTabBarController*)[(BalanceNavigationController *)[self navigationController] parentViewController];
    colorSingleton = [ColorSingleton sharedColorSingleton];
    numberFormatterSingleton = [NumberFormatterSingleton sharedMyNumberFormatterSingleton];
    [self refresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Fetch the devices from persistent data store
    [self.tableView reloadData];
    self.navigationItem.title = groupTabBarController.group[@"name"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Reload Page
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
    colorSingleton = [ColorSingleton sharedColorSingleton];
}

#pragma mark - Table view data source
- (void)setIndexOfLowestBalance
{
    [groupTabBarController.groupUsers enumerateObjectsUsingBlock:^(PFObject *groupUser, NSUInteger idx, BOOL *stop) {
        if([groupUser[@"balance"] doubleValue] < lowestBalance){
            lowestBalance = [groupUser[@"balance"] doubleValue];
            indexOfLowestBalance = idx;
        };
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self setIndexOfLowestBalance];
    return groupTabBarController.groupUsers.count;
    
}

- (void)setBalance:(PFObject *)groupUser groupUserCell:(UITableViewCell *)groupUserCell
{
    NSNumber *balance = groupUser[@"balance"];
    [groupUserCell.detailTextLabel setText:[[numberFormatterSingleton getCurrencyNumberFormatter] stringFromNumber:balance]];
    if([balance longValue] >= 0){
        [groupUserCell.detailTextLabel setTextColor:[colorSingleton getGreenColor]];
    } else {
        [groupUserCell.detailTextLabel setTextColor:[colorSingleton getRedColor]];
    }
}

- (void)setUserName:(PFObject *)groupUser groupUserCell:(UITableViewCell *)groupUserCell
{
    NSString *userName = groupUser[@"user"][@"name"];
    [groupUserCell.textLabel setText:userName];
}

- (void)setBorderColor:(UITableViewCell *)groupUserCell indexPath:(NSIndexPath *)indexPath
{
    if(indexOfLowestBalance == indexPath.row && lowestBalance != 0.0){
        [groupUserCell.viewForBaselineLayout.layer setBorderColor:[colorSingleton getRedColor].CGColor];
        [groupUserCell.viewForBaselineLayout.layer setBorderWidth:2.0f];
        lowestBalance = 0.0;
    } else {
        [groupUserCell.viewForBaselineLayout.layer setBorderColor:[UIColor clearColor].CGColor];
    }
}

- (UITableViewCell *)tableView:(UITableView *)groupUserTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"groupUserCell";
    UITableViewCell *groupUserCell = [groupUserTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *groupUser = groupTabBarController.groupUsers[indexPath.row];
    
    [self setUserName:groupUser groupUserCell:groupUserCell];
    [self setBalance:groupUser groupUserCell:groupUserCell];
    
    PFFile *thumbnail = groupUser[@"user"][@"profilePic"];
    groupUserCell.imageView.image = [UIImage imageNamed:@"person_grey.jpg"];
    
    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        // Now that the data is fetched, update the cell's image property.
        if(!error) {
            groupUserCell.imageView.image = [UIImage imageWithData:data];
        } else {
            groupUserCell.imageView.image = [UIImage imageNamed:@"pill.png"];
        }
        
        /* Profile Image Format */
        groupUserCell.imageView.layer.cornerRadius = groupUserCell.imageView.frame.size.width / 2;
        groupUserCell.imageView.clipsToBounds = YES;
        groupUserCell.imageView.layer.borderWidth = 3.0f;
        groupUserCell.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        /* */
        groupUserCell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }];

    

    [self setBorderColor:groupUserCell indexPath:indexPath];
    
    return groupUserCell;
}

#pragma mark - Navigation
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

#pragma mark - Buttons
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
