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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.allowsMultipleSelection = YES;
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
    
    [groupUserCell.nameLabel setText:[NSString stringWithFormat:@"%@", groupName]];
    [groupUserCell.multiplier setText:[NSString stringWithFormat:@"1"]];
    //groupUserCell.imageView.image = [UIImage imageNamed:@"images.jpeg"];
    
    return groupUserCell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //NSMutableArray *selectedExpenseUsers = [[NSMutableArray alloc] init];
    for (NSIndexPath *selectedExpensePayerIndex in self.tableView.indexPathsForSelectedRows) {
        SelectUsersCell *groupUserCell = (SelectUsersCell *)[self.tableView cellForRowAtIndexPath:selectedExpensePayerIndex];
        
        PFObject *selectedUser = [navigationController.groupUsers objectAtIndex:selectedExpensePayerIndex.row];
        for (PFObject *expenseParticipator in navigationController.expenseParticipators) {
            if([expenseParticipator[@"user"] isEqual:selectedUser]){
                [expenseParticipator setValue:@([groupUserCell.multiplier.text integerValue])forKey:@"usageMultiplier"];
            }
        }
    }
    
//    if ([segue.identifier isEqualToString:@"showSummary"]) {
//        NewExpenseNavigationController *navigationController = (NewExpenseNavigationController *)[self navigationController];
//        navigationController.expenseUsers=selectedExpenseUsers;
//    }
}

@end
