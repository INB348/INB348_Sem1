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
NSMutableArray *paymentMultipliers;
NSMutableArray *usageMultipliers;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.paymentKeysAndMultipliers = [self getIndexesAndMultipliersOfObjects:@"payment" multiplierType:@"paymentMultiplier"];
    self.usageKeysAndMultipliers = [self getIndexesAndMultipliersOfObjects:@"usage" multiplierType:@"usageMultiplier"];
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

-(void)expensePayerIndexes:(NSMutableDictionary *)indexesAndMultipliers{
    NSLog(@"Setting new Payers");
    self.paymentKeysAndMultipliers = indexesAndMultipliers;
}

-(void)expenseUserIndexes:(NSMutableDictionary *)indexesAndMultipliers{
    NSLog(@"Setting new Users");
    self.usageKeysAndMultipliers = indexesAndMultipliers;
}

-(NSNumber*)getPartOfPayment{
    double numberOfPayers=0;
    NSArray *multipliers = [self.paymentKeysAndMultipliers allValues];
    for (NSNumber *multiplier in multipliers) {
        numberOfPayers += [multiplier doubleValue];
    }
    return [NSNumber numberWithDouble:[self.amountTextField.text doubleValue]/numberOfPayers];
}

-(NSNumber*)getPartOfUsage{
    double numberOfUsers=0;
    NSArray *multipliers = [self.usageKeysAndMultipliers allValues];
    for (NSNumber *multiplier in multipliers) {
        numberOfUsers += [multiplier doubleValue];
    }
    return [NSNumber numberWithDouble:[self.amountTextField.text doubleValue]/numberOfUsers];
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

- (NSMutableDictionary *)getIndexesAndMultipliersOfObjects:(NSString *) type multiplierType:(NSString *) multiplierType {
    NSMutableDictionary *indexesAndMultipliers = [NSMutableDictionary dictionary];
    
    for (PFObject *expenseParticipator in self.oldExpenseParticipators) {
        if(![expenseParticipator[type] isEqual:@0] ){
            for (PFObject *groupUser in self.groupUsers) {
                if([[(PFObject *)expenseParticipator[@"user"] objectId] isEqualToString:groupUser.objectId]){
                    [indexesAndMultipliers setObject:expenseParticipator[multiplierType] forKey:[@([self.groupUsers indexOfObject:groupUser]) stringValue]];
                }
            }
        }
    }
    return indexesAndMultipliers;
}

-(void)calculateNewUserBalance{
    NSMutableArray *updatedUsers = [NSMutableArray array];
    for (PFObject *user in self.groupUsers) {
        PFQuery *query = [PFQuery queryWithClassName:@"ExpenseParticipator"];
        [query whereKey:@"user" equalTo:user];
        NSArray *objects = [query findObjects];
        NSLog(@"Found %d ExpenseParticipations for User %@",objects.count, user[@"user"][@"name"]);
        double balance = 0;
        for (PFObject *expenseParticipator in objects) {
            double payment = (double)[expenseParticipator[@"payment"] doubleValue]*[expenseParticipator[@"paymentMultiplier"] doubleValue];
            double usage = (double)[expenseParticipator[@"usage"] doubleValue]*[expenseParticipator[@"usageMultiplier"] doubleValue];
            balance = balance+payment-usage;
        }
        [user setValue:[NSNumber numberWithDouble:balance] forKey:@"balance"];
        [updatedUsers addObject:user];
    }
    [PFObject saveAllInBackground:updatedUsers block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            
        }
    }];
}
-(BOOL)isKeyInPaymentDictionary:(int) key{
    return [[self.paymentKeysAndMultipliers allKeys] containsObject:[@(key) stringValue]];
}
-(BOOL)isKeyInUsageDictionary:(int) key{
    return [[self.usageKeysAndMultipliers allKeys] containsObject:[@(key) stringValue]];
}
-(BOOL)isKeyInPaymentOrUsageDictionary:(int) key{
    return [self isKeyInPaymentDictionary:key] || [self isKeyInUsageDictionary:key];
}

-(void)addNewExpenseParticipators{
    NSMutableArray *newExpenseParticipators = [NSMutableArray array];
    for (int i = 0; i<self.groupUsers.count; i++) {
        if([self isKeyInPaymentOrUsageDictionary:i]){
            PFObject *expenseParticipator = [PFObject objectWithClassName:@"ExpenseParticipator"];
            PFObject *groupUser = [self.groupUsers objectAtIndex:i];
            [expenseParticipator setObject:groupUser forKey:@"user"];
            [expenseParticipator setObject:self.expense forKey:@"expense"];
            
            if([self isKeyInPaymentDictionary:i]){
                [expenseParticipator setValue:[self getPartOfPayment] forKey:@"payment"];
                NSNumber *multiplier = [self.paymentKeysAndMultipliers valueForKey:[@(i) stringValue]];
                [expenseParticipator setValue:multiplier forKey:@"paymentMultiplier"];
            } else{
                [expenseParticipator setValue:@0 forKey:@"payment"];
                [expenseParticipator setValue:@0 forKey:@"paymentMultiplier"];
            }
            if([self isKeyInUsageDictionary:i]){
                [expenseParticipator setValue:[self getPartOfUsage] forKey:@"usage"];
                NSNumber *multiplier = [self.usageKeysAndMultipliers valueForKey:[@(i) stringValue]];
                [expenseParticipator setValue:multiplier forKey:@"usageMultiplier"];
            }else{
               [expenseParticipator setValue:@0 forKey:@"usage"];
                [expenseParticipator setValue:@0 forKey:@"usageMultiplier"];
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
        [destinationViewController setDelegate:self];
    }
}

- (IBAction)delete:(id)sender {
    [self.expense deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [PFObject deleteAllInBackground:self.oldExpenseParticipators block:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    [self calculateNewUserBalance];
                    [self.delegate refresh];
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else{
                    NSLog(@"%@", error);
                }
            }];
            
        }else{
            NSLog(@"%@", error);
        }
    }];
}
@end
