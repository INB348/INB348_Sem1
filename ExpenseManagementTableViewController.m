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

- (PFObject *)getGroup{
    return [(GroupTabBarController *)[(HistoryNavigationViewController *)[self navigationController] parentViewController] group];
}

- (NSArray *)getGroupUsers{
    return [(GroupTabBarController *)[(HistoryNavigationViewController *)[self navigationController] parentViewController] groupUsers];
}

- (NSArray *)getGroupExpenses{
    return [(GroupTabBarController *)[(HistoryNavigationViewController *)[self navigationController] parentViewController] expenses];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customSetup];

    self.title = [self getGroup][@"name"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self getGroupExpenses].count;
    
}

- (UITableViewCell *)tableView:(UITableView *)groupUserTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"expenseHistoryCell";
    UITableViewCell *expenseHistoryCell = [groupUserTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *groupExpense = [self getGroupExpenses][indexPath.row];
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
        destNavigationController.groupUsers = [self getGroupUsers];
        destNavigationController.group = [self getGroup];
    }
    if ([segue.identifier isEqualToString:@"editExpenseSegue"]) {
        NewExpenseNavigationController *destNavigationController = segue.destinationViewController;
        destNavigationController.groupUsers = [self getGroupUsers];
        destNavigationController.group = [self getGroup];
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        destNavigationController.oldExpense = [self getGroupExpenses][indexPath.row];
    }
}

@end
