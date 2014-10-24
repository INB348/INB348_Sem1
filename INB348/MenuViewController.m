//
//  MenuViewController.m
//  RevealControllerStoryboardExample
//
//  Created by Nick Hodapp on 1/9/13.
//  Copyright (c) 2013 CoDeveloper. All rights reserved.
//

#import "MenuViewController.h"
#import "LogInViewController.h"
#import <Parse/Parse.h>

@implementation SWUITableViewCell
@end

@implementation MenuViewController


- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    // configure the destination view controller:

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    switch ( indexPath.row )
    {
        case 0:
            CellIdentifier = @"Username";
            break;
            
        case 1:
            CellIdentifier = @"Notifications";
            break;
            
        case 2:
            CellIdentifier = @"Groups";
            break;

        case 3:
            CellIdentifier = @"Settings";
            break;
            
        case 4:
            CellIdentifier = @"About";
            break;
            
        case 5:
            CellIdentifier = @"LogOut";
            break;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];
    
    if(indexPath.row == 0) {
        UILabel *nameLabel = (UILabel*) [cell viewWithTag:100];
        nameLabel.text = [[PFUser currentUser] objectForKey:@"name"];
        
        // Configure the cell
        PFFile *thumbnail = [[PFUser currentUser] objectForKey:@"profilePic"];
        UIImageView *chosenImage = (UIImageView*) [cell viewWithTag:99];
        chosenImage.image = [UIImage imageNamed:@"pill.png"];
        
        [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            // Now that the data is fetched, update the cell's image property.
            if(!error) {
                chosenImage.image = [UIImage imageWithData:data];
            } else {
                chosenImage.image = [UIImage imageNamed:@"pill.png"];
            }
        }];
    }

 
    return cell;
}

#pragma mark state preservation / restoration
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // TODO save what you need here
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // TODO restore what you need here
    
    [super decodeRestorableStateWithCoder:coder];
}

- (void)applicationFinishedRestoringState {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // TODO call whatever function you need to visually restore
}

-(IBAction)logOut:(id)sender {
//    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
//                                                         bundle:nil];
//    LogInViewController *add =
//    [storyboard instantiateViewControllerWithIdentifier:@"LogIn"];
//    
//    [self presentViewController:add
//                       animated:YES
//                     completion:nil];
}

@end
