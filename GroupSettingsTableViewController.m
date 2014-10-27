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
@end

@implementation GroupSettingsTableViewController
GroupTabBarController *groupTabBarController;

#pragma mark - Setup
- (void)viewDidLoad
{
    groupTabBarController =(GroupTabBarController*)[(GroupSettingsNavigationViewController *)[self navigationController] parentViewController];
    [super viewDidLoad];
    [self setUpRevealViewController];
}
- (void)viewDidAppear:(BOOL)animated{
    self.navigationItem.title = groupTabBarController.group[@"name"];
    self.nameLabel.text = groupTabBarController.group[@"name"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [groupTabBarController.group setValue:self.nameLabel.text forKey:@"name"];
    [groupTabBarController.group saveInBackground];
}

- (void)setUpRevealViewController
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

- (BOOL)isBalanceZero{
    for (PFObject *groupUser in groupTabBarController.groupUsers) {
        if(![groupUser[@"balance"] isEqualToNumber:@0]){
            return false;
        }
    }
    return true;
}

- (IBAction)nameChanged:(id)sender {
    self.navigationItem.title = self.nameLabel.text;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showMembers"]) {
        MembersTableViewController *membersViewController = segue.destinationViewController;
        membersViewController.groupUsers = groupTabBarController.groupUsers;
        membersViewController.group = groupTabBarController.group;
    }
    if ([segue.identifier isEqualToString:@"addMember"]) {
        AddMemberNavigationController *addMemberNavigationController = segue.destinationViewController;
        AddMemberToGroupViewController *addMemberViewController = (AddMemberToGroupViewController *)addMemberNavigationController.topViewController;
        addMemberViewController.groupUsers = groupTabBarController.groupUsers;
        addMemberViewController.group = groupTabBarController.group;
    }
    
}

#pragma mark - Buttons
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)deleteGroup:(id)sender {
    if([self isBalanceZero]){
        [groupTabBarController.group deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                for(PFObject *groupUser in groupTabBarController.groupUsers){
                    [groupUser deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if(succeeded){
                            [self dismissViewControllerAnimated:YES completion:nil];
                        } else{
                            NSLog(@"%@", error);
                        }
                    }];
                }
            }else{
                NSLog(@"%@", error);
            }
        }];
    } else{
        NSLog(@"Users balance is not 0");
    }
}
@end
