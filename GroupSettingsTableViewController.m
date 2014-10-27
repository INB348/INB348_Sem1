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

- (void)viewDidLoad
{
    groupTabBarController =(GroupTabBarController*)[(GroupSettingsNavigationViewController *)[self navigationController] parentViewController];
    [super viewDidLoad];
    [self customSetup];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewDidAppear:(BOOL)animated{
    self.navigationItem.title = groupTabBarController.group[@"name"];
    self.nameLabel.text = groupTabBarController.group[@"name"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [groupTabBarController.group setValue:self.nameLabel.text forKey:@"name"];
    [groupTabBarController.group saveInBackground];
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

- (BOOL)isBalanceZero{
    for (PFObject *groupUser in groupTabBarController.groupUsers) {
        if(![groupUser[@"balance"] isEqualToNumber:@0]){
            return false;
        }
    }
    return true;
}

- (IBAction)deleteGroup:(id)sender {

    if([self isBalanceZero]){
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Are you sure you want to delete this group?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [errorAlertView show];
        
    } else{
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Users balance are not equal 0" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorAlertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]){
        //cancel clicked ...do your action
    } else {
        [groupTabBarController.group deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                for(PFObject *groupUser in groupTabBarController.groupUsers){
                    [groupUser deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if(succeeded){
                            [self dismissViewControllerAnimated:YES completion:nil];
                        } else{
                            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            [errorAlertView show];
                        }
                    }];
                }
            } else {
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [errorAlertView show];
            }
        }];

    }
}

- (IBAction)nameChanged:(id)sender {
    self.navigationItem.title = self.nameLabel.text;
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"showMembers"]) {
//        MembersTableViewController *membersViewController = segue.destinationViewController;
//        membersViewController.groupUsers = groupTabBarController.groupUsers;
//        membersViewController.group = groupTabBarController.group;
//    }
//    if ([segue.identifier isEqualToString:@"addMember"]) {
//        AddMemberNavigationController *addMemberNavigationController = segue.destinationViewController;
//        AddMemberToGroupViewController *addMemberViewController = (AddMemberToGroupViewController *)addMemberNavigationController.topViewController;
//        addMemberViewController.groupUsers = groupTabBarController.groupUsers;
//        addMemberViewController.group = groupTabBarController.group;
//    }
//    
//}

-(IBAction)add:(id)sender {
    BOOL isValidEmail = [self NSStringIsValidEmail: self.usernameLabel.text];
    
    if (isValidEmail) {
        NSLog(@"Attempting to add member");
        for (PFObject *groupUser in groupTabBarController.groupUsers) {
            if([groupUser[@"user"][@"username"] isEqualToString:self.usernameLabel.text]){
                NSString *string1 = self.usernameLabel.text;
                NSString *note = [NSString stringWithFormat: @"'%@' is already a part of this group.", string1];
                
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:note delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [errorAlertView show];
                return;
            }
        }
        
        PFQuery *existingUser = [PFUser query];
        [existingUser whereKey:@"username" equalTo:self.usernameLabel.text];
        [existingUser getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved the object.");
                
                PFQuery *query = [PFUser query];
                [query whereKey:@"username" equalTo:self.usernameLabel.text];
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (!error) {
                        NSLog(@"%@", object.objectId);
                        PFObject *newGroupUser = [PFObject objectWithClassName:@"UserGroup"];
                        [newGroupUser setObject:groupTabBarController.group forKey:@"group"];
                        [newGroupUser setObject:object forKey:@"user"];
                        [newGroupUser setValue:[NSNumber numberWithBool:NO] forKey:@"accepted"];
                        [newGroupUser setValue:@0 forKey:@"balance"];
                        [newGroupUser saveEventually];
                        
                        // Send invite message notification
                        PFQuery *query = [PFQuery queryWithClassName:@"Group"];
                        [query getObjectInBackgroundWithId:groupTabBarController.group.objectId block:^(PFObject *gName, NSError *error) {
                            
                            NSString *string1 = [[PFUser currentUser] objectForKey:@"name"];
                            NSString *string2 = gName[@"name"];
                            NSString *note = [NSString stringWithFormat: @"'%@' invited you to join '%@'", string1, string2];
                            
                            PFObject *addMemberNotification = [PFObject objectWithClassName:@"Notifications"];
                            [addMemberNotification setObject:[PFUser currentUser] forKey:@"fromUser"];
                            [addMemberNotification setObject:object forKey:@"toUser"];
                            [addMemberNotification setObject:note forKey:@"note"];
                            [addMemberNotification setValue:[NSNumber numberWithBool:NO] forKey:@"read"];
                            [addMemberNotification saveEventually];
                        }];
                        
                        self.usernameLabel.text = @"";
                        
                        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"All done!" message:@" Your message has been successfully sent :)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [errorAlertView show];

                    } else {
                        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [errorAlertView show];
                    }
                    
                }];
            
            } else {
                
                NSString *string2 = self.usernameLabel.text;
                NSString *note2 = [NSString stringWithFormat: @"'%@' doesn't exist.", string2];
                
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:note2 delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [errorAlertView show];
            }
        }];
    
    } else {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You enter email address in wrong format. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorAlertView show];
    }
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkEmail {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkEmail];
}

@end
