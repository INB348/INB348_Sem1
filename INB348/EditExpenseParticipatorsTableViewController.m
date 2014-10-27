//
//  EditExpenseParticipatorsTableViewController.m
//  INB348
//
//  Created by Kristian M Matzen on 11/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "EditExpenseParticipatorsTableViewController.h"

@interface EditExpenseParticipatorsTableViewController ()
@property (nonatomic, assign) id currentResponder;
@end

@implementation EditExpenseParticipatorsTableViewController
@synthesize delegate;

#pragma mark - Setup
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.groupUsers.count;
}

-(BOOL)isKeyInKeyAndMultiplierDictionary:(int) key{
    return [[self.keysAndMultipliers allKeys] containsObject:[@(key) stringValue]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectUsersCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editExpenseParticipatorsCell" forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *groupUser = self.groupUsers[indexPath.row];
    NSString *userName = groupUser[@"user"][@"name"];
    
    //Setup delegate for tap
    cell.multiplier.delegate = self;
    
    if([self isKeyInKeyAndMultiplierDictionary:indexPath.row]){
        [tableView selectRowAtIndexPath:indexPath
                               animated:NO
                         scrollPosition:UITableViewScrollPositionMiddle];
        NSString *key =[@(indexPath.row) stringValue];
        NSNumber *multiplier =[self.keysAndMultipliers objectForKey:key];
        [cell.multiplier setText:[multiplier stringValue]];
    } else{
      [cell.multiplier setText:@"1"];
    }
    [cell.nameLabel setText:[NSString stringWithFormat:@"%@", userName]];
    
    
    return cell;
}

#pragma mark - Buttons
- (void)showOkAlertButton:(NSString *)message {
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [errorAlertView show];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    if(self.tableView.indexPathsForSelectedRows.count != 0){
    NSMutableDictionary *indexesAndMultipliers = [NSMutableDictionary dictionary];
    for (NSIndexPath *selectedExpensePayerIndex in self.tableView.indexPathsForSelectedRows) {
        SelectUsersCell *groupUserCell = (SelectUsersCell *)[self.tableView cellForRowAtIndexPath:selectedExpensePayerIndex];
        NSNumber *multiplier = @([groupUserCell.multiplier.text intValue]);
        if([multiplier intValue] >0){
        [indexesAndMultipliers setObject:multiplier forKey:[@(selectedExpensePayerIndex.row) stringValue]];
        }else {
            NSLog(@"Multiplier must be at least 1");
            [self showOkAlertButton:@"Multiplier must be greater than 0.\nPlease try again."];
            return;
        }
    }
    [self.delegate setExpenseParticipatorIndexes:indexesAndMultipliers];
    [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        NSLog(@"You must select at least 1 Member");
        [self showOkAlertButton:@"You must select at least 1 Member.\nPlease try again."];
    }
}

#pragma mark - Highlight and Tap
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentResponder = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.currentResponder = nil;
}

- (void)resignOnTap:(id)iSender {
    [self.currentResponder resignFirstResponder];
}

- (void)setUpTap
{
    //Setup tap
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    
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
