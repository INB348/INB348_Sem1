//
//  NewExpenseWhoPaidTableViewController.m
//  INB348
//
//  Created by Kristian Matzen on 18/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "NewExpenseWhoPaidTableViewController.h"

@interface NewExpenseWhoPaidTableViewController ()
@end

@implementation NewExpenseWhoPaidTableViewController
NewExpenseNavigationController *navigationController;

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [self.tableView cellForRowAtIndexPath:indexPath];
    tableViewCell.accessoryView.hidden = NO;
    //tableViewCell.selected = NO;
    // if you don't use custom image tableViewCell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    tableViewCell.accessoryView.hidden = YES;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return navigationController.groupUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)groupUserTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"whoPaidCell";
    UITableViewCell *groupUserCell = [groupUserTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *groupUser = navigationController.groupUsers[indexPath.row];
    NSString *userName = groupUser[@"user"][@"name"];
    
    [groupUserCell.textLabel setText:[NSString stringWithFormat:@"%@", userName]];
    groupUserCell.imageView.image = [UIImage imageNamed:@"images.jpeg"];
    
    return groupUserCell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Adding selected users to array
    NSMutableArray *selectedExpensePayers = [[NSMutableArray alloc] init];
    for (NSIndexPath *selectedExpensePayerIndex in self.tableView.indexPathsForSelectedRows) {
        [selectedExpensePayers addObject:[navigationController.groupUsers objectAtIndex:selectedExpensePayerIndex.row]];
    }
    
    if ([segue.identifier isEqualToString:@"showForWhom"]) {
        navigationController.expensePayers=selectedExpensePayers;
    }
}

@end
