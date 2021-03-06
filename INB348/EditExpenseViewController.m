//
//  EditExpenseViewController.m
//  INB348
//
//  Created by Kristian M Matzen on 11/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "EditExpenseViewController.h"
#import "ColorSingleton.h"
#import "NumberFormatterSingleton.h"

@interface EditExpenseViewController ()
@property (nonatomic, assign) id currentResponder;
@end

@implementation EditExpenseViewController
@synthesize delegate;
NSMutableArray *paymentMultipliers;
NSMutableArray *usageMultipliers;
ColorSingleton *colorSingleton;
NumberFormatterSingleton *numberFormatterSingleton;

#pragma mark - Setup
- (void)setOldExpenseValues {
    self.paymentKeysAndMultipliers = [self getIndexesAndMultipliersOfObjects:@"payment" multiplierType:@"paymentMultiplier"];
    self.usageKeysAndMultipliers = [self getIndexesAndMultipliersOfObjects:@"usage" multiplierType:@"usageMultiplier"];
    self.nameTextField.text=self.expense[@"name"];
    self.amountTextField.text=[self.expense[@"amount"] stringValue];
    self.datePicker.date=self.expense[@"date"];
    self.descriptionTextView.text=self.expense[@"description"];
}

- (void)setDescriptionTextViewBorders {
    self.descriptionTextView.layer.borderWidth = 2.0f;
    self.descriptionTextView.layer.borderColor = [[colorSingleton getLightGreyColor] CGColor];
    self.descriptionTextView.layer.cornerRadius = 8;
}

- (void)setScrollView {
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 700)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Edit Expense";
    
    [self setOldExpenseValues];
    [self setUpTap];
    [self setDescriptionTextViewBorders];
    [self setScrollView];
    
    colorSingleton = [ColorSingleton sharedColorSingleton];
    
    [self.nameTextField setTintColor:[colorSingleton getBlueColor]];
    [self.amountTextField setTintColor:[colorSingleton getBlueColor]];
    [self.descriptionTextView setTintColor:[colorSingleton getBlueColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Payment and Usage Handling
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

#pragma mark - Update
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
    if(![self.expense[@"description"] isEqualToString:self.descriptionTextView.text]){
        NSLog(@"Description changed");
        [self.expense setValue:[self returnStringIfNotNull:self.descriptionTextView.text] forKey:@"description"];
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
        NSLog(@"Found %lu ExpenseParticipations for User %@",(unsigned long)objects.count, user[@"user"][@"name"]);
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
            PFUser *currentUser = [PFUser currentUser];
//            NSString *moneyFormat = [[numberFormatterSingleton getNumberFormatter] stringFromNumber:expenseParticipator[@"usage"]];
            NSString *note = [NSString stringWithFormat: @"%@ has edited the '%@' expense.", currentUser[@"name"], expenseParticipator[@"expense"][@"name"]];
            PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
            [notification setObject:[PFUser currentUser] forKey:@"fromUser"];
            [notification setObject:expenseParticipator[@"user"][@"user"] forKey:@"toUser"];
            [notification setObject:note forKey:@"note"];
            [notification setValue:[NSNumber numberWithBool:NO] forKey:@"read"];
            [notification saveEventually];
            
        }
    }
    
    [PFObject saveAllInBackground:newExpenseParticipators block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [self calculateNewUserBalance];
            [self.delegate refresh];
        }
    }];
}

- (void)showOkAlertButton:(NSString *)message {
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [errorAlertView show];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editOptions"]) {
        EditOptionsTableViewController *destinationViewController = (EditOptionsTableViewController *)segue.destinationViewController;
        destinationViewController.groupUsers = self.groupUsers;
        [destinationViewController setDelegate:self];
    }
}

#pragma mark - Buttons

- (IBAction)save:(id)sender {
    if(![self.nameTextField.text isEqualToString:@""]){
        if(![self.amountTextField.text isEqualToString:@""]){
            if([self isValuesChanged]){
                [self.expense saveInBackground];
            }
            
            [PFObject deleteAllInBackground:self.oldExpenseParticipators block:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    [self addNewExpenseParticipators];
                }
            }];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else {
            NSLog(@"Must set an Amount");
            [self showOkAlertButton:@"Amount can't be blank.\nPlease try again."];
        }
    }else {
        NSLog(@"Must choose a Name");
        [self showOkAlertButton:@"Name can't be blank.\nPlease try again."];
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)deleteButton:(id)sender {
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

#pragma mark - Tap out of keyboard
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentResponder = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.currentResponder = nil;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    self.currentResponder = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.currentResponder = nil;
}

- (void)resignOnTap:(id)iSender {
    [self.currentResponder resignFirstResponder];
}

- (void)setUpTap
{
    //Set Textfield delegates
    self.amountTextField.delegate = self;
    self.nameTextField.delegate = self;
    self.descriptionTextView.delegate = self;
    
    //Setup tap
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    
}

#pragma mark - 'Done' out of Keyboard
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.currentResponder == nil) {
        return NO;
    }
    
    return YES;
}

@end
