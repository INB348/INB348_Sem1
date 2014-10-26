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
NSMutableArray *participators;

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
    navigationController = (NewExpenseNavigationController *)[self navigationController];
    
    participators = [NSMutableArray array];
    
    for (PFObject *groupUser in navigationController.groupUsers) {
       if([self isUserAnExpensePayer:groupUser] || [self isUserAnExpenseUser:groupUser]){
           PFObject *participator = [PFObject objectWithClassName:@"ExpenseParticipator"];
           [participator setObject:groupUser forKey:@"user"];
           if([self isUserAnExpensePayer:groupUser]){
               [participator setValue:[self getPartOfPayment] forKey:@"payment"];
           }else{
               [participator setValue:@0 forKey:@"payment"];
           }
           if([self isUserAnExpenseUser:groupUser]){
                [participator setObject:[self getPartOfUsage] forKey:@"usage"];
           }else{
               [participator setValue:@0 forKey:@"usage"];
           }
           [participators addObject:participator];
       }
    }
    
    
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
    return participators.count;
}

-(NSNumber*)getNewBalance:(PFObject*)participator{
    return [NSNumber numberWithDouble:[participator[@"user"][@"balance"] doubleValue]+[participator[@"payment"]  doubleValue]-[participator[@"usage"]  doubleValue]];
}


-(NSNumber*)getPartOfPayment{
    return [NSNumber numberWithDouble:[navigationController.amount doubleValue]/navigationController.expensePayers.count];
}

-(NSNumber*)getPartOfUsage{
    return [NSNumber numberWithDouble:[navigationController.amount doubleValue]/navigationController.expenseUsers.count];
}

-(BOOL)isUserAnExpensePayer:(PFObject *)user{
    for (PFObject *expensePayer in navigationController.expensePayers) {
        if([expensePayer.objectId isEqualToString:user.objectId]){
            return true;
        }
    }
    return false;
}

-(BOOL)isUserAnExpenseUser:(PFObject *)user{
    for (PFObject *expenseUser in navigationController.expenseUsers) {
        if([expenseUser.objectId isEqualToString:user.objectId]){
            return true;
        }
    }
    return false;
}

- (void)setColorByValue:(UILabel *)label value:(long) value
{
    if(value > 0){
        [label setTextColor:[UIColor greenColor]];
    } else if(value < 0){
        [label setTextColor:[UIColor redColor]];
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
    
    // Configure the cell...
    PFObject *expenseParticipator = participators[indexPath.row];
   
    //Set name
    NSString *userName = expenseParticipator[@"user"][@"user"][@"name"];
    [summaryCell.nameLabel setText:[NSString stringWithFormat:@"%@", userName]];
    
    //Set old balance
    NSNumber *oldBalance = expenseParticipator[@"user"][@"balance"];
    [summaryCell.oldBalance setText:[NSString stringWithFormat:@"%@", [oldBalance stringValue]]];
    [self setColorByValue:summaryCell.oldBalance value:[expenseParticipator[@"user"][@"balance"] longValue]];
    
    //Set payment
    [summaryCell.payed setText:[NSString stringWithFormat:@"%@", [expenseParticipator[@"payment"] stringValue]]];
    [self setColorByValue:summaryCell.payed value:[expenseParticipator[@"payment"] longValue]];
    
    //Set usage
    [summaryCell.used setText:[NSString stringWithFormat:@"%@", [expenseParticipator[@"usage"] stringValue]]];
    [self setColorByValue:summaryCell.used value:-[expenseParticipator[@"usage"] longValue]];
    
    //Set new balance
    NSNumber *newBalance = [self getNewBalance:expenseParticipator];
    [summaryCell.updatedBalance setText:[NSString stringWithFormat:@"%@", [newBalance stringValue]]];
    [self setColorByValue:summaryCell.updatedBalance value:[newBalance longValue]];
    
    return summaryCell;
}

-(NSString *)returnStringIfNotNull:(NSString*)string{
    if(string == nil){
        return @"";
    } else{
        return string;
    }
}

-(void)calculateNewUserBalance{
    NSMutableArray *updatedGroupUsers = [NSMutableArray array];
    for (PFObject *user in navigationController.groupUsers) {
        PFQuery *query = [PFQuery queryWithClassName:@"ExpenseParticipator"];
        [query whereKey:@"user" equalTo:user];
        NSArray *objects = [query findObjects];
        NSLog(@"Found %d ExpenseParticipations for User %@",objects.count, user[@"user"][@"name"]);
        double balance = 0;
        for (PFObject *expenseParticipator in objects) {
            double payment = (double)[expenseParticipator[@"payment"] doubleValue];
            double usage = (double)[expenseParticipator[@"usage"] doubleValue];
            balance = balance+payment-usage;
        }
        [user setValue:[NSNumber numberWithDouble:balance] forKey:@"balance"];
        [updatedGroupUsers addObject:user];
    }
    [PFObject saveAllInBackground:updatedGroupUsers block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [navigationController.delegate refresh];
        }
    }];
}

- (IBAction)save:(id)sender {
    // Create a new Expense
    PFObject *expense= [PFObject objectWithClassName:@"Expense"];
    [expense setValue:[self returnStringIfNotNull:navigationController.name] forKey:@"name"];
    [expense setValue:navigationController.amount forKey:@"amount"];
    [expense setValue:navigationController.date forKey:@"date"];
    [expense setValue:[self returnStringIfNotNull:navigationController.comment] forKey:@"description"];
    [expense setObject:navigationController.group forKey:@"group"];
    [expense saveInBackground];
    
    NSMutableArray *newParticipators = [NSMutableArray array];
    for (PFObject *participator in participators) {
        [participator setObject:expense forKey:@"expense"];
        [newParticipators addObject:participator];
    }
    [PFObject saveAllInBackground:newParticipators block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [self calculateNewUserBalance];
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
