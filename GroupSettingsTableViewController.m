//
//  GroupSettingsTableViewController.m
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "GroupSettingsTableViewController.h"
#import "SWRevealViewController.h"

@interface GroupSettingsTableViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@property (strong) PFObject  *group;
@end

@implementation GroupSettingsTableViewController
GroupTabBarController *groupTabBarController;
@synthesize membersTableView;

- (void)viewDidLoad
{
    groupTabBarController =(GroupTabBarController*)[(GroupSettingsNavigationViewController *)[self navigationController] parentViewController];
    [super viewDidLoad];
    [self customSetup];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = groupTabBarController.group[@"name"];
    self.nameLabel.text = groupTabBarController.group[@"name"];
}

- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.revealButtonItem setTarget: revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return groupTabBarController.groupUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)groupUserTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"memberCell";
    UITableViewCell *memberCell = [self.membersTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *name =[NSString stringWithFormat:@"%@", groupTabBarController.groupUsers[indexPath.row][@"user"][@"name"]];
    [memberCell.textLabel setText:name];
    
    return memberCell;
}

- (IBAction)addMember:(id)sender {
}

- (IBAction)deleteGroup:(id)sender {
}
@end
