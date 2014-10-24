//
//  GroupRequestsTableViewController.m
//  INB348
//
//  Created by Kristian M Matzen on 23/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "GroupRequestsTableViewController.h"

@interface GroupRequestsTableViewController ()
@property (strong) NSArray *requestedGroupUsers;
@end

@implementation GroupRequestsTableViewController
NSString *count = @"0";
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self updateRequestedGroupsCount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (void)updateRequestedGroupsCount{
    PFQuery *query = [PFQuery queryWithClassName:@"UserGroup"];
    [query includeKey:@"group"];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [query whereKey:@"user" equalTo:currentUser];
        [query whereKey:@"accepted" equalTo:[NSNumber numberWithBool:NO]];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            count = [NSString stringWithFormat:@"%d", number];
            [self.tableView reloadData];
        }];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupRequestsCell" forIndexPath:indexPath];
    [cell.detailTextLabel setText:count];
    
    return cell;
}

@end
