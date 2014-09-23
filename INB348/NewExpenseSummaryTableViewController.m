//
//  NewExpenseSummaryTableViewController.m
//  INB348
//
//  Created by Kristian Matzen on 18/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "NewExpenseSummaryTableViewController.h"

@interface NewExpenseSummaryTableViewController ()

@end

@implementation NewExpenseSummaryTableViewController
NSNumber *expenseUserAmount;
NSNumber *expensePayerAmount;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSNumber *numberOfExpensePayers = [NSNumber numberWithInt:[self.expenseUsers count]];
    double expensePayerAmountDouble = [self.amount doubleValue]/[numberOfExpensePayers doubleValue];
    expensePayerAmount = [NSNumber numberWithDouble:expensePayerAmountDouble];
    
    NSNumber *numberOfExpenseUsers = [NSNumber numberWithInt:[self.expenseUsers count]];
    double expenseUserAmountDouble = [self.amount doubleValue]/[numberOfExpenseUsers doubleValue];
    expenseUserAmount = [NSNumber numberWithDouble:expenseUserAmountDouble];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.expenseUsers.count;
}

-(NSNumber*)getNewExpensePayerBalance:(NSNumber*)oldBalance:(NSNumber*)change{
    return [NSNumber numberWithDouble:[oldBalance doubleValue]+[change doubleValue]];
}

-(NSNumber*)getNewExpenseUserBalance:(NSNumber*)oldBalance:(NSNumber*)change{
    return [NSNumber numberWithDouble:[oldBalance doubleValue]-[change doubleValue]];
}

- (UITableViewCell *)tableView:(UITableView *)groupUserTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"summaryCell";
    UITableViewCell *groupUserCell = [groupUserTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *groupUser = self.expensePayers[indexPath.row];
    NSString *userName = groupUser[@"user"][@"name"];
    NSNumber *balance = groupUser[@"balance"];
    NSNumber *newBalance = [self getNewExpensePayerBalance:balance:expensePayerAmount];
    NSString *details = [[[[[balance stringValue] stringByAppendingString:@" + "] stringByAppendingString:[expenseUserAmount stringValue]] stringByAppendingString:@" = " ] stringByAppendingString:[newBalance stringValue]];
    
    [groupUserCell.textLabel setText:[NSString stringWithFormat:@"%@", userName]];
    [groupUserCell.detailTextLabel setText:[NSString stringWithFormat:@"%@", details]];
    groupUserCell.imageView.image = [UIImage imageNamed:@"images.jpeg"];
    
    return groupUserCell;
}

-(NSString *)returnStringIfNotNull:(NSString*)string{
    if(string == nil){
        return @"";
    } else{
        return string;
    }
}

- (IBAction)save:(id)sender {
    // Create a new Expense
    PFObject *expense= [PFObject objectWithClassName:@"Expense"];
    [expense setValue:[self returnStringIfNotNull:self.name] forKey:@"name"];
    [expense setValue:self.amount forKey:@"amount"];
    [expense setValue:self.date forKey:@"date"];
    [expense setValue:[self returnStringIfNotNull:self.description] forKey:@"description"];
    [expense setObject:self.group forKey:@"group"];
    [expense saveInBackground];
    
    //Create each ExpensePayer
    for (PFObject *user in self.expensePayers) {
        PFObject *expensePayer= [PFObject objectWithClassName:@"ExpensePayment"];
        [expensePayer setObject:expense forKey:@"expense"];
        [expensePayer setObject:user forKey:@"user"];
        [expensePayer setValue:expensePayerAmount forKey:@"amount"];
        [expensePayer saveInBackground];
        
        [user setValue:[self getNewExpensePayerBalance:user[@"balance"]:expensePayerAmount] forKey:@"balance"];
        [user save];
    }
    
    //Create each ExpenseUser
    for (PFObject *user in self.expenseUsers) {
        PFObject *expenseUser= [PFObject objectWithClassName:@"ExpenseUsage"];
        [expenseUser setObject:expense forKey:@"expense"];
        [expenseUser setObject:user forKey:@"user"];
        [expenseUser setValue:expenseUserAmount forKey:@"amount"];
        [expenseUser saveInBackground];
        
        [user setValue:[self getNewExpenseUserBalance:user[@"balance"]:expenseUserAmount] forKey:@"balance"];
        [user save];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
