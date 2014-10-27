//
//  NewExpenseForWhomTableViewController.m
//  INB348
//
//  Created by Kristian Matzen on 18/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "NewExpenseForWhomTableViewController.h"

@interface NewExpenseForWhomTableViewController ()
@property (nonatomic, assign) id currentResponder;
@end

@implementation NewExpenseForWhomTableViewController
NewExpenseNavigationController *navigationController;

#pragma mark - Setup
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
    self.tableView.allowsMultipleSelection = YES;
    [self setUpTap];
}

- (void)viewDidAppear:(BOOL)animated{
    for (PFObject *expenseParticipator in navigationController.expenseParticipators) {
        [expenseParticipator setValue:@(0) forKey:@"usageMultiplier"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    tableViewCell.accessoryView.hidden = NO;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    tableViewCell.accessoryView.hidden = YES;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return navigationController.groupUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)groupUserTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"forWhomCell";
    SelectUsersCell *groupUserCell = [groupUserTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *groupUser = navigationController.groupUsers[indexPath.row];
    NSString *groupName = groupUser[@"user"][@"name"];
    
    //Setup delegate for tap
    groupUserCell.multiplier.delegate = self;
    
    [groupUserCell.nameLabel setText:[NSString stringWithFormat:@"%@", groupName]];
    [groupUserCell.multiplier setText:[NSString stringWithFormat:@"1"]];
    
    return groupUserCell;
}

#pragma mark - Highlight and Tap
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentResponder = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.currentResponder = nil;
}

- (void)resignOnTap:(id)iSender {
    if(self.currentResponder != nil){
        [self.currentResponder resignFirstResponder];
    }
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

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.currentResponder == nil) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Buttons

- (void)showOkAlertButton:(NSString *)message {
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [errorAlertView show];
}

- (IBAction)next:(id)sender {
    if(self.tableView.indexPathsForSelectedRows.count != 0){
        for (NSIndexPath *selectedExpensePayerIndex in self.tableView.indexPathsForSelectedRows) {
            SelectUsersCell *groupUserCell = (SelectUsersCell *)[self.tableView cellForRowAtIndexPath:selectedExpensePayerIndex];
            
            PFObject *selectedUser = [navigationController.groupUsers objectAtIndex:selectedExpensePayerIndex.row];
            for (PFObject *expenseParticipator in navigationController.expenseParticipators) {
                if([expenseParticipator[@"user"] isEqual:selectedUser]){
                    NSNumber *multiplier = @([groupUserCell.multiplier.text intValue]);
                    if([multiplier intValue] >0){
                        [expenseParticipator setValue:multiplier forKey:@"usageMultiplier"];
                        [self performSegueWithIdentifier:@"showSummary" sender:self];
                    } else {
                        NSLog(@"Multiplier must be at least 1");
                        [self showOkAlertButton:@"Multiplier must be greater than 0.\nPlease try again."];
                    }
                }
            }
        }
    } else{
        NSLog(@"You must select at least 1 Member");
        [self showOkAlertButton:@"You must select at least 1 Member.\nPlease try again."];
    }
}
@end
