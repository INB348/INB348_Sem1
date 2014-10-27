//
//  ExpenseManagementTableViewController.m
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "ExpenseManagementTableViewController.h"
#import "SWRevealViewController.h"
#import "ColorSingleton.h"

@interface ExpenseManagementTableViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@end

@implementation ExpenseManagementTableViewController
GroupTabBarController *groupTabBarController;
ColorSingleton *colorSingleton;

#pragma mark - Setup
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpRevealViewController];
    groupTabBarController = (GroupTabBarController *)[(HistoryNavigationViewController *)[self navigationController] parentViewController];

    [self refresh];
    colorSingleton = [ColorSingleton sharedColorSingleton];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    self.navigationItem.title = groupTabBarController.group[@"name"];
}

- (void)setUpRevealViewController
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.revealButtonItem setTarget: revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
}

#pragma mark - Reload Table
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
    self.navigationItem.title = groupTabBarController.group[@"name"];
}

#pragma mark - Table view data source
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
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.##"];
    [expenseHistoryCell.detailTextLabel setText:[fmt stringFromNumber:expenseAmount]];
    [expenseHistoryCell.detailTextLabel setTextColor:[colorSingleton getBlueColor]];
    
    return expenseHistoryCell;
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
    if ([segue.identifier isEqualToString:@"editExpenseSegue"]) {
        EditExpenseNavigationController *destNavigationController = segue.destinationViewController;
        EditExpenseViewController *destViewController = (EditExpenseViewController *)destNavigationController.topViewController;
        
        destViewController.groupUsers = groupTabBarController.groupUsers;
        destViewController.group = groupTabBarController.group;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *oldExpense = groupTabBarController.expenses[indexPath.row];
        
        //Retrieve expensepayers
        PFQuery *expensePayersQuery = [PFQuery queryWithClassName:@"ExpenseParticipator"];
        [expensePayersQuery whereKey:@"expense" equalTo:oldExpense];
        destViewController.oldExpenseParticipators = [expensePayersQuery findObjects];
        
        destViewController.expense = oldExpense;
        
        [destViewController setDelegate:self];
    }
}

#pragma mark - Buttons
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
