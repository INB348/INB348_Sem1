//
//  NewExpenseForWhomTableViewController.m
//  INB348
//
//  Created by Kristian Matzen on 18/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "NewExpenseForWhomTableViewController.h"

@interface NewExpenseForWhomTableViewController ()

@end

@implementation NewExpenseForWhomTableViewController

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
    self.tableView.allowsMultipleSelection = YES;
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
    //tableViewCell.selected = NO;
    // if you don't use custom image tableViewCell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    tableViewCell.accessoryView.hidden = YES;
    //tableViewCell.selected = YES;
    // if you don't use custom image tableViewCell.accessoryType = UITableViewCellAccessoryNone;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.groupUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)groupUserTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"forWhomCell";
    UITableViewCell *groupUserCell = [groupUserTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *groupUser = self.groupUsers[indexPath.row];
    NSString *groupName = groupUser[@"user"][@"name"];
    
    [groupUserCell.textLabel setText:[NSString stringWithFormat:@"%@", groupName]];
    groupUserCell.imageView.image = [UIImage imageNamed:@"images.jpeg"];
    
    return groupUserCell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSMutableArray *selectedExpenseUsers = [[NSMutableArray alloc] init];
    for (NSIndexPath *selectedExpenseUserIndex in self.tableView.indexPathsForSelectedRows) {
        [selectedExpenseUsers addObject:[self.groupUsers objectAtIndex:selectedExpenseUserIndex.row]];
    }
    
    if ([segue.identifier isEqualToString:@"showSummary"]) {
        NewExpenseSummaryTableViewController *destViewController = segue.destinationViewController;
        destViewController.name = self.name;
        destViewController.amount = self.amount;
        destViewController.date = self.date;
        destViewController.description = self.description;
        destViewController.expensePayers=self.expensePayers;
        destViewController.expenseUsers=selectedExpenseUsers;
        destViewController.group = self.group;
    }
}

@end
