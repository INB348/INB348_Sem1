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
@property (strong) NSMutableArray *expenses;
@property (strong) NSMutableArray *usedExpenseParticipators;
@property (strong) NSMutableArray *payedExpenseParticipators;
@end

@implementation UserExpenseHistoryTableViewController
bool readyForReload = false;
ColorSingleton *colorSingleton;
NumberFormatterSingleton *numberFormatterSingleton;

#pragma mark - Setup
- (void)viewDidLoad {
    [super viewDidLoad];
    [self refresh];
    self.expenses = [NSMutableArray array];
    self.payedExpenseParticipators = [NSMutableArray array];
    self.usedExpenseParticipators = [NSMutableArray array];
    colorSingleton = [ColorSingleton sharedColorSingleton];
    numberFormatterSingleton = [NumberFormatterSingleton sharedMyNumberFormatterSingleton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Reload Table

- (void)refresh{
    PFQuery *expensesQuery = [PFQuery queryWithClassName:@"ExpenseParticipator"];
    [expensesQuery whereKey:@"user" equalTo:self.groupUser];
    //[expensesQuery whereKey:@"payment" notEqualTo:@0];
    [expensesQuery includeKey:@"expense"];
    [expensesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu Expenses.", (unsigned long)objects.count);
            
            // Do something with the found objects
            for (PFObject *expenseParticipator in objects) {
                if(![expenseParticipator[@"payment"] isEqualToNumber:@0]){
                    [self.payedExpenseParticipators addObject:expenseParticipator];
                }
                if(![expenseParticipator[@"usage"] isEqualToNumber:@0]){
                    [self.usedExpenseParticipators addObject:expenseParticipator];
                }
                [self.expenses addObject:expenseParticipator[@"expense"]];
            }
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    

    
//    expensesQuery = [PFQuery queryWithClassName:@"ExpenseParticipator"];
//    [expensesQuery whereKey:@"user" equalTo:self.groupUser];
//    [expensesQuery whereKey:@"usage" notEqualTo:@0];
//    [expensesQuery includeKey:@"expense"];
//    [expensesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            // The find succeeded.
//            NSLog(@"Successfully retrieved %lu Expenses.", (unsigned long)objects.count);
//            
//            // Do something with the found objects
//            self.usedExpenseParticipators = objects;
//            [self reloadIfReady];
//        } else {
//            // Log details of the failure
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
    
    self.navigationItem.title = self.groupUser[@"user"][@"name"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch(section){
        case 0:
            return 1;
            break;
        case 1:
            return self.payedExpenseParticipators.count;
            break;
        case 2:
            return self.usedExpenseParticipators.count;
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0;
            break;
    }
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
            //myLabel.text = NSLocalizedString(@"", @"");
            break;
        case 1:
            myLabel.text = NSLocalizedString(@"Paid", @"Paid");
            break;
        case 2:
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

- (void)setExpenseAmount:(PFObject *)expenseParticipator expenseHistoryCell:(HistoryCell *)expenseHistoryCell {
    PFObject *expense = expenseParticipator[@"expense"];
    [expenseHistoryCell.amountLabel setText:[[numberFormatterSingleton getCurrencyNumberFormatter] stringFromNumber:expense[@"amount"]]];
    [expenseHistoryCell.amountLabel setTextColor:[colorSingleton getBlueColor]];
}
- (void)setTotalExpenseAmount:(HistoryCell *)expenseHistoryCell{
    double totalBalance = 0;
    for (PFObject *expense in self.expenses) {
        totalBalance += [expense[@"amount"] doubleValue];
    }
    [expenseHistoryCell.amountLabel setText:[[numberFormatterSingleton getCurrencyNumberFormatter] stringFromNumber:[NSNumber numberWithDouble:totalBalance]]];
    [expenseHistoryCell.amountLabel setTextColor:[colorSingleton getBlueColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryCell *expenseHistoryCell = [tableView dequeueReusableCellWithIdentifier:@"userExpenseCell" forIndexPath:indexPath];
    PFObject *expenseParticipator;
    
    switch([indexPath section]){
        case 0:
            [expenseHistoryCell.userAmountLabel setText:[[numberFormatterSingleton getCurrencyNumberFormatter] stringFromNumber:self.groupUser[@"balance"]]];
            [expenseHistoryCell.nameLabel setText:@"User Balance:"];
            [expenseHistoryCell.createdAtLabel setText:@"All Expenses:"];
            [self setTotalExpenseAmount:expenseHistoryCell];
            expenseHistoryCell.accessoryType = UITableViewCellAccessoryNone;
            expenseHistoryCell.userInteractionEnabled = NO;
            if([self.groupUser[@"balance"] longValue] >= 0){
                [expenseHistoryCell.userAmountLabel setTextColor:[colorSingleton getGreenColor]];
            } else {
                [expenseHistoryCell.userAmountLabel setTextColor:[colorSingleton getRedColor]];
            }
            break;
        case 1:
            expenseParticipator = self.payedExpenseParticipators[indexPath.row];
            [expenseHistoryCell.userAmountLabel setText:[[numberFormatterSingleton getCurrencyNumberFormatter] stringFromNumber:expenseParticipator[@"payment"]]];
            [expenseHistoryCell.userAmountLabel setTextColor:[colorSingleton getGreenColor]];
            
            [self setExpenseAmount:expenseParticipator expenseHistoryCell:expenseHistoryCell];
            [self setNameLabel:expenseParticipator expenseHistoryCell:expenseHistoryCell];
            [self setCreatedAtLabel:expenseParticipator expenseHistoryCell:expenseHistoryCell];
            break;
        case 2:
            expenseParticipator = self.usedExpenseParticipators[indexPath.row];
            [expenseHistoryCell.userAmountLabel setText:[[numberFormatterSingleton getCurrencyNumberFormatter] stringFromNumber:expenseParticipator[@"usage"]]];
            [expenseHistoryCell.userAmountLabel setTextColor:[colorSingleton getRedColor]];
            
            [self setExpenseAmount:expenseParticipator expenseHistoryCell:expenseHistoryCell];
            [self setNameLabel:expenseParticipator expenseHistoryCell:expenseHistoryCell];
            [self setCreatedAtLabel:expenseParticipator expenseHistoryCell:expenseHistoryCell];
            break;
    }
    
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
            case 1:
                oldExpense = self.payedExpenseParticipators[indexPath.row][@"expense"];
                break;
            case 2:
                oldExpense = self.usedExpenseParticipators[indexPath.row][@"expense"];
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
