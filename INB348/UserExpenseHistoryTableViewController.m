//
//  UserExpenseHistoryTableViewController.m
//  INB348
//
//  Created by Kristian M Matzen on 25/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "UserExpenseHistoryTableViewController.h"
#import "ColorSingleton.h"

@interface UserExpenseHistoryTableViewController ()
@property (strong) NSArray *expenses;
@property (strong) NSArray *usedExpenseParticipator;
@property (strong) NSArray *payedExpenseParticipator;
@end

@implementation UserExpenseHistoryTableViewController
bool readyForReload = false;
ColorSingleton *colorSingleton;

#pragma mark - Setup
- (void)setBalanceLabel {
    NSNumber *balance = self.groupUser[@"balance"];
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.##"];
    self.balanceLabel.title = [fmt stringFromNumber:balance];
    
    if([balance longValue] >= 0){
        [self.balanceLabel setTintColor:[colorSingleton getGreenColor]];
    } else {
        [self.balanceLabel setTintColor:[colorSingleton getRedColor]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refresh];
    colorSingleton = [ColorSingleton sharedColorSingleton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Reload Table
- (void)reloadIfReady{
    if(readyForReload){
        [self.tableView reloadData];
        readyForReload = @false;
    } else {
        readyForReload = @true;
    }
}

- (void)refresh{
    PFQuery *expensesQuery = [PFQuery queryWithClassName:@"ExpenseParticipator"];
    [expensesQuery whereKey:@"user" equalTo:self.groupUser];
    [expensesQuery whereKey:@"payment" notEqualTo:@0];
    [expensesQuery includeKey:@"expense"];
    [expensesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu Expenses.", (unsigned long)objects.count);
            
            // Do something with the found objects
            self.payedExpenseParticipator = objects;
            [self reloadIfReady];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    expensesQuery = [PFQuery queryWithClassName:@"ExpenseParticipator"];
    [expensesQuery whereKey:@"user" equalTo:self.groupUser];
    [expensesQuery whereKey:@"usage" notEqualTo:@0];
    [expensesQuery includeKey:@"expense"];
    [expensesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu Expenses.", (unsigned long)objects.count);
            
            // Do something with the found objects
            self.usedExpenseParticipator = objects;
            [self reloadIfReady];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    self.navigationItem.title = self.groupUser[@"user"][@"name"];
    [self setBalanceLabel];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch(section){
        case 0:
            return self.payedExpenseParticipator.count;
            break;
        case 1:
            return self.usedExpenseParticipator.count;
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Paid For", @"Paid For");
            break;
        case 1:
            sectionName = NSLocalizedString(@"Used", @"Used");
            break;
            // ...
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *expenseHistoryCell = [tableView dequeueReusableCellWithIdentifier:@"userExpenseCell" forIndexPath:indexPath];
    PFObject *expensePayer;
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.##"];
    
    switch([indexPath section]){
        case 0:
            expensePayer = self.payedExpenseParticipator[indexPath.row];
            [expenseHistoryCell.detailTextLabel setText:[fmt stringFromNumber:expensePayer[@"payment"]]];
            [expenseHistoryCell.detailTextLabel setTextColor:[colorSingleton getGreenColor]];
            break;
        case 1:
            expensePayer = self.usedExpenseParticipator[indexPath.row];
            [expenseHistoryCell.detailTextLabel setText:[fmt stringFromNumber:expensePayer[@"usage"]]];
            [expenseHistoryCell.detailTextLabel setTextColor:[colorSingleton getRedColor]];
            break;
    }
    NSString *expenseName = expensePayer[@"expense"][@"name"];

    [expenseHistoryCell.textLabel setText:[NSString stringWithFormat:@"%@", expenseName]];
    
    return expenseHistoryCell;
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editExpenseSegue"]) {
        EditExpenseNavigationController *destNavigationController = segue.destinationViewController;
        EditExpenseViewController *destViewController = (EditExpenseViewController *)destNavigationController.topViewController;
        
        destViewController.groupUsers = self.groupUsers;
        destViewController.group = self.group;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *oldExpense;
        
        switch([indexPath section]){
            case 0:
                oldExpense = self.payedExpenseParticipator[indexPath.row][@"expense"];
                break;
            case 1:
                oldExpense = self.usedExpenseParticipator[indexPath.row][@"expense"];
                break;
        }
        
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
