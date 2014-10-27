//
//  EditExpenseParticipatorsTableViewController.m
//  INB348
//
//  Created by Kristian M Matzen on 11/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "EditExpenseParticipatorsTableViewController.h"

@interface EditExpenseParticipatorsTableViewController ()

@end

@implementation EditExpenseParticipatorsTableViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

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

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    NSMutableDictionary *indexesAndMultipliers = [NSMutableDictionary dictionary];
    for (NSIndexPath *selectedExpensePayerIndex in self.tableView.indexPathsForSelectedRows) {
        SelectUsersCell *groupUserCell = (SelectUsersCell *)[self.tableView cellForRowAtIndexPath:selectedExpensePayerIndex];
        [indexesAndMultipliers setObject:@([groupUserCell.multiplier.text intValue]) forKey:[@(selectedExpensePayerIndex.row) stringValue]];
    }
    [self.delegate setExpenseParticipatorIndexes:indexesAndMultipliers];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
