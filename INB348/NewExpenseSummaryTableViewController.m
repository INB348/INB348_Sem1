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
NewExpenseNavigationController *navigationController;
NSMutableArray *expenseParticipators;
ColorSingleton *colorSingleton;

#pragma mark - Setup
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setExpenseParticipators
{
    expenseParticipators = navigationController.expenseParticipators;
    for (int i = 0; i<expenseParticipators.count; i++) {
        PFObject *expenseParticipator = expenseParticipators[i];
        if(![expenseParticipator[@"paymentMultiplier"] isEqualToNumber:@0] || ![expenseParticipator[@"usageMultiplier"] isEqualToNumber:@0]){
            if([expenseParticipator[@"paymentMultiplier"] doubleValue] != 0){
                [expenseParticipator setValue:[self getPartOfPayment] forKey:@"payment"];
            }
            if([expenseParticipator[@"usageMultiplier"] doubleValue] != 0){
                [expenseParticipator setValue:[self getPartOfUsage] forKey:@"usage"];
            }
        } else {
            [expenseParticipators removeObjectAtIndex:i];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    navigationController = (NewExpenseNavigationController *)[self navigationController];
    [self setExpenseParticipators];
    colorSingleton = [ColorSingleton sharedColorSingleton];
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
    return expenseParticipators.count;
}

- (void)setColorByValue:(UILabel *)label value:(long) value
{
    if(value > 0){
        [label setTextColor:[colorSingleton getGreenColor]];
    } else if(value < 0){
        [label setTextColor:[colorSingleton getRedColor]];
    }

}

- (UITableViewCell *)tableView:(UITableView *)groupUserTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SummaryCell";
    SummaryCell *summaryCell = (SummaryCell *)[groupUserTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (summaryCell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SummaryCell" owner:self options:nil];
        summaryCell = [nib objectAtIndex:0];
    }
    
    PFObject *expenseParticipator = navigationController.expenseParticipators[indexPath.row];
    
    [self setLabels:expenseParticipator summaryCell:summaryCell];
    
    return summaryCell;
}

- (void)setLabel:(NSNumber *)labelValue fmt:(NSNumberFormatter *)fmt summaryCell:(UILabel *)labelName
{
    [labelName setText:[fmt stringFromNumber:labelValue]];
    [self setColorByValue:labelName value:[labelValue longValue]];
}

- (void)setLabels:(PFObject *)expenseParticipator summaryCell:(SummaryCell *)summaryCell
{
    NSString *userName = expenseParticipator[@"user"][@"user"][@"name"];
    [summaryCell.nameLabel setText:[NSString stringWithFormat:@"%@", userName]];
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.##"];
    
    [self setLabel:expenseParticipator[@"user"][@"balance"] fmt:fmt summaryCell:summaryCell.oldBalance];
    
    NSNumber *paymentMultiplied = @([expenseParticipator[@"payment"] doubleValue]*[expenseParticipator[@"paymentMultiplier"] doubleValue]);
    [self setLabel:paymentMultiplied fmt:fmt summaryCell:summaryCell.payed];
    
    NSNumber *usageMultiplied = @([expenseParticipator[@"usage"] doubleValue]*[expenseParticipator[@"usageMultiplier"] doubleValue]);
    [self setLabel:usageMultiplied fmt:fmt summaryCell:summaryCell.used];
    
    NSNumber *newBalance = [self getNewBalance:expenseParticipator];
    [self setLabel:newBalance fmt:fmt summaryCell:summaryCell.updatedBalance];
}

-(NSString *)returnStringIfNotNull:(NSString*)string{
    if(string == nil){
        return @"";
    } else{
        return string;
    }
}

#pragma mark - Calculations
-(NSNumber*)getNewBalance:(PFObject*)participator{
    return [NSNumber numberWithDouble:[participator[@"user"][@"balance"] doubleValue]+[participator[@"payment"]  doubleValue]*[participator[@"paymentMultiplier"] doubleValue]-[participator[@"usage"]  doubleValue]*[participator[@"usageMultiplier"] doubleValue]];
}


-(NSNumber*)getPartOfPayment{
    double numberOfPayers=0;
    for (PFObject *expensePayer in navigationController.expenseParticipators) {
        numberOfPayers += [expensePayer[@"paymentMultiplier"] doubleValue];
    }
    return [NSNumber numberWithDouble:[navigationController.amount doubleValue]/numberOfPayers];
}

-(NSNumber*)getPartOfUsage{
    double numberOfUsers=0;
    for (PFObject *expensePayer in navigationController.expenseParticipators) {
        numberOfUsers += [expensePayer[@"usageMultiplier"] doubleValue];
    }
    return [NSNumber numberWithDouble:[navigationController.amount doubleValue]/numberOfUsers];
}

- (double)getUpdatedBalance:(NSArray *)objects {
    double balance = 0;
    for (PFObject *expenseParticipator in objects) {
        double payment = (double)[expenseParticipator[@"payment"] doubleValue]*[expenseParticipator[@"paymentMultiplier"] doubleValue];
        double usage = (double)[expenseParticipator[@"usage"] doubleValue]*[expenseParticipator[@"usageMultiplier"] doubleValue];
        balance = balance+payment-usage;
    }
    return balance;
}

- (NSArray *)getUsersExpenseParticipations:(PFObject *)user {
    PFQuery *expenseParticipatorQuery = [PFQuery queryWithClassName:@"ExpenseParticipator"];
    [expenseParticipatorQuery whereKey:@"user" equalTo:user];
    NSArray *expenseParticipators = [expenseParticipatorQuery findObjects];
    NSLog(@"Found %lu ExpenseParticipations for User %@",(unsigned long)expenseParticipators.count, user[@"user"][@"name"]);
    return expenseParticipators;
}

-(void)updateUserBalance{
    NSMutableArray *updatedGroupUsers = [NSMutableArray array];
    for (PFObject *user in navigationController.groupUsers) {
        NSArray *expenseParticipators = [self getUsersExpenseParticipations:user];
        double balance = [self getUpdatedBalance:expenseParticipators];
        [user setValue:[NSNumber numberWithDouble:balance] forKey:@"balance"];
        [updatedGroupUsers addObject:user];
    }
    [PFObject saveAllInBackground:updatedGroupUsers block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [navigationController.delegate refresh];
        }
    }];
}

#pragma mark - Buttons
- (IBAction)save:(id)sender {
    PFObject *expense;
    expense = [self createNewExpense];
    
    [self createNewExpenseParticipators:expense];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (PFObject *)createNewExpense {
    // Create a new Expense
    PFObject *expense= [PFObject objectWithClassName:@"Expense"];
    [expense setValue:[self returnStringIfNotNull:navigationController.name] forKey:@"name"];
    [expense setValue:navigationController.amount forKey:@"amount"];
    [expense setValue:navigationController.date forKey:@"date"];
    [expense setValue:[self returnStringIfNotNull:navigationController.comment] forKey:@"description"];
    [expense setObject:navigationController.group forKey:@"group"];
    [expense saveInBackground];
    return expense;
}

- (void)createNewExpenseParticipators:(PFObject *)expense {
    NSMutableArray *newParticipators = [NSMutableArray array];
    for (PFObject *participator in navigationController.expenseParticipators) {
        [participator setObject:expense forKey:@"expense"];
        [newParticipators addObject:participator];
    }
    [PFObject saveAllInBackground:newParticipators block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [self updateUserBalance];
        }
    }];
}
@end
