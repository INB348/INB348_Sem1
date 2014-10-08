//
//  ExpenseManagementTableViewController.m
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "ExpenseManagementTableViewController.h"
#import "SWRevealViewController.h"

@interface ExpenseManagementTableViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@end

@implementation ExpenseManagementTableViewController
GroupTabBarController *groupTabBarController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customSetup];
    groupTabBarController = (GroupTabBarController *)[(HistoryNavigationViewController *)[self navigationController] parentViewController];

    self.title = groupTabBarController.group[@"name"];
    [self refresh];

}

- (void)refresh{
    PFQuery *expensesQuery = [PFQuery queryWithClassName:@"Expense"];
    [expensesQuery whereKey:@"group" equalTo:groupTabBarController.group];
    [expensesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d Expenses.", objects.count);
            
            // Do something with the found objects
            groupTabBarController.expenses = [objects mutableCopy];
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return groupTabBarController.expenses.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)groupUserTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"expenseHistoryCell";
    UITableViewCell *expenseHistoryCell = [groupUserTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *groupExpense = groupTabBarController.expenses[indexPath.row];
    NSString *expenseName = groupExpense[@"name"];
    NSNumber *expenseAmount = groupExpense[@"amount"];
    
    [expenseHistoryCell.textLabel setText:[NSString stringWithFormat:@"%@", expenseName]];
    [expenseHistoryCell.detailTextLabel setText:[expenseAmount stringValue]];
    
    return expenseHistoryCell;
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
        destNavigationController.groupUsers = groupTabBarController.groupUsers;
        destNavigationController.group = groupTabBarController.group;
    }
    if ([segue.identifier isEqualToString:@"editExpenseSegue"]) {
        NewExpenseNavigationController *destNavigationController = segue.destinationViewController;
        destNavigationController.groupUsers = groupTabBarController.groupUsers;
        destNavigationController.group = groupTabBarController.group;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *oldExpense = groupTabBarController.expenses[indexPath.row];
        
        //Retrieve expensepayers
        PFQuery *expensePayersQuery = [PFQuery queryWithClassName:@"ExpensePayer"];
        [expensePayersQuery whereKey:@"expense" equalTo:oldExpense];
        [expensePayersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %d ExpensePayers.", objects.count);
                destNavigationController.oldExpensePayers = objects;
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        //Retrieve expenseusers
        PFQuery *expenseUsersQuery = [PFQuery queryWithClassName:@"ExpenseUser"];
        [expenseUsersQuery whereKey:@"expense" equalTo:oldExpense];
        [expenseUsersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %d ExpenseUsers.", objects.count);
                destNavigationController.oldExpenseUsers = objects;
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        destNavigationController.oldExpense = oldExpense;
        
    }
}

@end
