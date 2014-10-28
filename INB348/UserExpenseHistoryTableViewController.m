//
//  UserExpenseHistoryTableViewController.m
//  INB348
//
//  Created by Kristian M Matzen on 25/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "UserExpenseHistoryTableViewController.h"
#import "ColorSingleton.h"
#import "NumberFormatterSingleton.h"

@interface UserExpenseHistoryTableViewController ()
@property (strong) NSArray *expenses;
@property (strong) NSArray *usedExpenseParticipator;
@property (strong) NSArray *payedExpenseParticipator;
@end

@implementation UserExpenseHistoryTableViewController
bool readyForReload = false;
ColorSingleton *colorSingleton;
NumberFormatterSingleton *numberFormatterSingleton;

#pragma mark - Setup

- (void)setBalanceLabel {
    NSNumber *balance = self.groupUser[@"balance"];
    NSNumberFormatter *fmt = [numberFormatterSingleton getNumberFormatter];
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
    numberFormatterSingleton = [NumberFormatterSingleton sharedMyNumberFormatterSingleton];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];

    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.font = [UIFont systemFontOfSize:20];
    myLabel.frame = CGRectMake(8, 0, 320, 30);

    headerView.backgroundColor = [colorSingleton getLightGreyColor];
    
    switch (section)
    {
        case 0:
            myLabel.text = NSLocalizedString(@"Paid", @"Paid");
            break;
        case 1:
            myLabel.text = NSLocalizedString(@"Used", @"Used");
            break;
        default:
            myLabel.text = @"";
            break;
    }
    
    [headerView addSubview:myLabel];
    
    return headerView;
}

- (void)setCreatedAtLabel:(PFObject *)expenseParticipator expenseHistoryCell:(HistoryCell *)expenseHistoryCell
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm dd-MM-yyyy"];
    PFObject *expense = expenseParticipator[@"expense"];
    NSDate *expenseCreatedAt = expense.createdAt;
    [expenseHistoryCell.createdAtLabel setText:[dateFormatter stringFromDate:expenseCreatedAt]];
}


- (void)setNameLabel:(PFObject *)expenseParticipator expenseHistoryCell:(HistoryCell *)expenseHistoryCell {
    NSString *expenseName = expenseParticipator[@"expense"][@"name"];
    [expenseHistoryCell.nameLabel setText:[NSString stringWithFormat:@"%@", expenseName]];
}

- (void)setTotalExpenseAmount:(PFObject *)expenseParticipator fmt:(NSNumberFormatter *)fmt expenseHistoryCell:(HistoryCell *)expenseHistoryCell {
    PFObject *expense = expenseParticipator[@"expense"];
    [expenseHistoryCell.amountLabel setText:[fmt stringFromNumber:expense[@"amount"]]];
    [expenseHistoryCell.amountLabel setTextColor:[colorSingleton getBlueColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryCell *expenseHistoryCell = [tableView dequeueReusableCellWithIdentifier:@"userExpenseCell" forIndexPath:indexPath];
    PFObject *expenseParticipator;
    
    NSNumberFormatter *fmt = [numberFormatterSingleton getNumberFormatter];
    
    switch([indexPath section]){
        case 0:
            expenseParticipator = self.payedExpenseParticipator[indexPath.row];
            [expenseHistoryCell.userAmountLabel setText:[fmt stringFromNumber:expenseParticipator[@"payment"]]];
            [expenseHistoryCell.userAmountLabel setTextColor:[colorSingleton getGreenColor]];
            break;
        case 1:
            expenseParticipator = self.usedExpenseParticipator[indexPath.row];
            [expenseHistoryCell.userAmountLabel setText:[fmt stringFromNumber:expenseParticipator[@"usage"]]];
            [expenseHistoryCell.userAmountLabel setTextColor:[colorSingleton getRedColor]];
            break;
    }
    
    [self setTotalExpenseAmount:expenseParticipator fmt:fmt expenseHistoryCell:expenseHistoryCell];
    [self setNameLabel:expenseParticipator expenseHistoryCell:expenseHistoryCell];
    [self setCreatedAtLabel:expenseParticipator expenseHistoryCell:expenseHistoryCell];
    
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
