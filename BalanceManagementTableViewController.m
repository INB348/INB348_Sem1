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

- (NSArray *)getGroupUsers{
    return [(GroupTabBarController *)[(BalanceNavigationController *)[self navigationController] parentViewController] groupUsers];
}

- (PFObject *)getGroup{
    return [(GroupTabBarController *)[(BalanceNavigationController *)[self navigationController] parentViewController] group];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customSetup];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = [self getGroup][@"name"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Fetch the devices from persistent data store
    //[self refresh];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self getGroupUsers].count;
    
}

- (UITableViewCell *)tableView:(UITableView *)groupUserTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"groupUserCell";
    UITableViewCell *groupUserCell = [groupUserTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *groupUser = [self getGroupUsers][indexPath.row];
    NSString *userName = groupUser[@"user"][@"name"];
    NSNumber *balance = groupUser[@"balance"];
    
    [groupUserCell.textLabel setText:[NSString stringWithFormat:@"%@", userName]];
    [groupUserCell.detailTextLabel setText:[balance stringValue]];
    groupUserCell.imageView.image = [UIImage imageNamed:@"images.jpeg"];
    
    return groupUserCell;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addNewExpenseSegue"]) {
        NewExpenseNavigationController *destNavigationController = segue.destinationViewController;
        destNavigationController.groupUsers = [self getGroupUsers];
        destNavigationController.group = [self getGroup];
    }
}

@end
