//
//  EditExpenseViewController.m
//  INB348
//
//  Created by Kristian M Matzen on 11/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "EditExpenseViewController.h"

@interface EditExpenseViewController ()

@end

@implementation EditExpenseViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.expensePayerIndexes = [self getIndexesOfObjects:@"payment"];
    self.expenseUserIndexes = [self getIndexesOfObjects:@"usage"];
    self.nameTextField.text=self.expense[@"name"];
    self.amountTextField.text=[self.expense[@"amount"] stringValue];
    self.datePicker.date=self.expense[@"date"];
    self.descriptionTextField.text=self.expense[@"description"];
    
    self.title = @"Edit Expense";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)expensePayerIndexes:(NSMutableArray *)indexes{
    NSLog(@"Setting new Payers");
    self.expensePayerIndexes = indexes;
}

-(void)expenseUserIndexes:(NSMutableArray *)indexes{
    NSLog(@"Setting new Users");
    self.expenseUserIndexes = indexes;
}

-(NSNumber*)getPartOfPayment{
    return [NSNumber numberWithDouble:[self.amountTextField.text doubleValue]/self.expensePayerIndexes.count];
}

-(NSNumber*)getPartOfUsage{
    return [NSNumber numberWithDouble:[self.amountTextField.text doubleValue]/self.expenseUserIndexes.count];
}

-(NSString *)returnStringIfNotNull:(NSString*)string{
    if(string == nil){
        return @"";
    } else{
        return string;
    }
}

- (BOOL)isValuesChanged{
    BOOL isValuesChanged = false;
    if(![self.expense[@"name"] isEqualToString:self.nameTextField.text]){
        NSLog(@"Name changed");
        [self.expense setValue:[self returnStringIfNotNull:self.nameTextField.text] forKey:@"name"];
        isValuesChanged = true;
    }
    if(![[NSString stringWithFormat:@"%@",self.expense[@"amount"]] isEqualToString:self.amountTextField.text]){
        NSLog(@"Amount changed");
        [self.expense setValue:[NSNumber numberWithDouble:[self.amountTextField.text doubleValue]] forKey:@"amount"];
        isValuesChanged = true;
    }
    if(![self.expense[@"date"] isEqualToDate:self.datePicker.date]){
        NSLog(@"Date changed");
        [self.expense setValue:self.datePicker.date forKey:@"date"];
        isValuesChanged = true;
    }
    if(![self.expense[@"description"] isEqualToString:self.descriptionTextField.text]){
        NSLog(@"Description changed");
        [self.expense setValue:[self returnStringIfNotNull:self.descriptionTextField.text] forKey:@"description"];
        isValuesChanged = true;
    }
    
    return isValuesChanged;
}

- (NSMutableArray *)getIndexesOfObjects:(NSString *) type{
    NSMutableArray *indexes = [NSMutableArray array];
    
    for (PFObject *expenseParticipator in self.oldExpenseParticipators) {
        if(![expenseParticipator[type] isEqual:@0] ){
            for (PFObject *groupUser in self.groupUsers) {
                if([[(PFObject *)expenseParticipator[@"user"] objectId] isEqualToString:groupUser.objectId]){
                    [indexes addObject:[NSNumber numberWithInteger:[self.groupUsers indexOfObject:groupUser]]];
                }
            }
        }
    }
    return indexes;
}

-(void)calculateNewUserBalance{
    for (PFObject *user in self.groupUsers) {
        PFQuery *query = [PFQuery queryWithClassName:@"ExpenseParticipator"];
        [query whereKey:@"user" equalTo:user];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                NSLog(@"Found %d ExpenseParticipations for User %@",objects.count, user[@"user"][@"name"]);
                double balance = 0;
                for (PFObject *expenseParticipator in objects) {
                    double payment = (double)[expenseParticipator[@"payment"] doubleValue];
                    double usage = (double)[expenseParticipator[@"usage"] doubleValue];
                    balance = balance+payment-usage;
                }
                [user setValue:[NSNumber numberWithDouble:balance] forKey:@"balance"];
                [user saveInBackground];
            } else{
                NSLog(@"Erro: %@",error);
            }
        }];
    }
}

-(void)addNewExpenseParticipators{
    NSMutableArray *newExpenseParticipators = [NSMutableArray array];
    for (int i = 0; i<self.groupUsers.count; i++) {
        if([self.expensePayerIndexes containsObject:[NSNumber numberWithInteger:i]] || [self.expenseUserIndexes containsObject:[NSNumber numberWithInteger:i]]){
            PFObject *expenseParticipator = [PFObject objectWithClassName:@"ExpenseParticipator"];
            PFObject *groupUser = [self.groupUsers objectAtIndex:i];
            [expenseParticipator setObject:groupUser forKey:@"user"];
            [expenseParticipator setObject:self.expense forKey:@"expense"];
            
            if([self.expensePayerIndexes containsObject:[NSNumber numberWithInteger:i]]){
                [expenseParticipator setValue:[self getPartOfPayment] forKey:@"payment"];
            } else{
                [expenseParticipator setValue:@0 forKey:@"payment"];
            }
            if([self.expenseUserIndexes containsObject:[NSNumber numberWithInteger:i]]){
                [expenseParticipator setValue:[self getPartOfUsage] forKey:@"usage"];
            }else{
               [expenseParticipator setValue:@0 forKey:@"usage"];
            }
            [newExpenseParticipators addObject:expenseParticipator];
        }
    }
    
    [PFObject saveAllInBackground:newExpenseParticipators block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [self calculateNewUserBalance];
            [self.delegate refresh];
        }
    }];
}

- (IBAction)save:(id)sender {
    if([self isValuesChanged]){
        [self.expense saveInBackground];
    }
    
    [PFObject deleteAllInBackground:self.oldExpenseParticipators block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [self addNewExpenseParticipators];
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editOptions"]) {
        EditOptionsTableViewController *destinationViewController = (EditOptionsTableViewController *)segue.destinationViewController;
        destinationViewController.groupUsers = self.groupUsers;
//        destinationViewController.expensePayerIndexes = self.expensePayerIndexes;
//        destinationViewController.expenseUserIndexes = self.expenseUserIndexes;
        [destinationViewController setDelegate:self];
    }
}
@end
