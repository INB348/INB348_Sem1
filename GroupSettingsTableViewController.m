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
@synthesize img_Profile = _img_Profile;

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
    
    self.nameLabel.delegate = self;
    self.usernameLabel.delegate = self;
    self.backupName = groupTabBarController.group[@"name"];
    /* Profile Image Format */
    PFFile *thumbnail = [groupTabBarController.group objectForKey:@"groupPic"];
//    self.img_Profile.image = [UIImage imageNamed:@"people_grey.jpg"];
    
    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        // Now that the data is fetched, update the cell's image property.
        if(!error) {
            self.img_Profile.image = [UIImage imageWithData:data];
        } else {
            self.img_Profile.image = [UIImage imageNamed:@"people_grey.jpg"];
        }
    }];
    
    self.img_Profile.layer.cornerRadius = self.img_Profile.frame.size.width / 2;
    self.img_Profile.clipsToBounds = YES;
    self.img_Profile.layer.borderWidth = 3.0f;
    self.img_Profile.layer.borderColor = [UIColor whiteColor].CGColor;
    /* */
}

/** Choose a photo in Photo Library */
- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
    
}

// Handle library navigation bar
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
}

/** Dismiss keyboard */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.nameLabel resignFirstResponder];
    [self.usernameLabel resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField) {
        [textField resignFirstResponder];
    }
    
    return NO;
}
/* end */


#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(256, 256));
    [chosenImage drawInRect: CGRectMake(0, 0, 256, 256)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Set maximun compression in order to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(newImage, 0.0f);
    UIImage *processedImage = [UIImage imageWithData:imageData];
    
    self.img_Profile.image = processedImage;
    
    /* Profile Image Format */
    self.img_Profile.layer.cornerRadius = self.img_Profile.frame.size.width / 2;
    self.img_Profile.clipsToBounds = YES;
    self.img_Profile.layer.borderWidth = 3.0f;
    self.img_Profile.layer.borderColor = [UIColor whiteColor].CGColor;
    /* */
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    //Profile Picture
    NSData *updatedImage = UIImagePNGRepresentation(self.img_Profile.image);
    NSString *imageName = [NSString stringWithFormat:@"%@_GroupPhoto", self.nameLabel.text];
    PFFile *imageFile = [PFFile fileWithName:imageName data:updatedImage];
    [groupTabBarController.group setObject:imageFile forKey:@"groupPic"];
    [groupTabBarController.group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            //
        } else{
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"The Internet connection appears to be offline. Please try it again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [errorAlertView show];
        }
    }];
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
/* end */

- (void)viewDidAppear:(BOOL)animated{
    self.navigationItem.title = groupTabBarController.group[@"name"];
    self.nameLabel.text = groupTabBarController.group[@"name"];
    NSLog(@"Teest: %@", self.backupName);
}

- (void)viewWillDisappear:(BOOL)animated {
    [groupTabBarController.group setValue:self.nameLabel.text forKey:@"name"];
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
//        [groupTabBarController.group deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if(succeeded){
//                for(PFObject *groupUser in groupTabBarController.groupUsers){
//                    [groupUser deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                        if(succeeded){
//                            [self dismissViewControllerAnimated:YES completion:nil];
//                        } else{
//                            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                            [errorAlertView show];
//                        }
//                    }];
//                }
//            } else {
//                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [errorAlertView show];
//            }
//        }];
//
        
        PFQuery *query = [PFQuery queryWithClassName:@"UserGroup"];
        [query whereKey:@"group" equalTo:groupTabBarController.group];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
                // Do something with the found objects
                for (PFObject *object in objects) {
                    [object deleteInBackground];
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        PFQuery *query2 = [PFQuery queryWithClassName:@"Expense"];
        [query2 whereKey:@"group" equalTo:groupTabBarController.group];
        [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
                // Do something with the found objects
                for (PFObject *object in objects) {
                    PFQuery *query3 = [PFQuery queryWithClassName:@"ExpenseParticipator"];
                    [query3 whereKey:@"expense" equalTo:object];
                    [query3 findObjectsInBackgroundWithBlock:^(NSArray *smObjects, NSError *error) {
                        if (!error) {
                            // The find succeeded.
                            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
                            // Do something with the found objects
                            for (PFObject *smObject in smObjects) {
                                [smObject deleteInBackground];
                            }
                        } else {
                            // Log details of the failure
                            NSLog(@"Error: %@ %@", error, [error userInfo]);
                        }
                    }];
                    
                    [object deleteInBackground];
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        PFQuery *query4 = [PFQuery queryWithClassName:@"Group"];
        [query4 whereKey:@"group" equalTo:groupTabBarController.group];
        [query4 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
                // Do something with the found objects
                for (PFObject *object in objects) {
                    [object deleteInBackground];
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
//        NSLog (@"%@", groupTabBarController.groupUsers);
        
        for (PFObject *groupUser in groupTabBarController.groupUsers) {
            NSLog(@"%@", groupUser);
            NSString *string1 = [[PFUser currentUser] objectForKey:@"name"];
            NSString *string2 = @"group";
            NSString *note = [NSString stringWithFormat: @"'%@' has deleted '%@' %@", string1, groupTabBarController.group[@"name"], string2];
            
            PFObject *deleteGroupNotification = [PFObject objectWithClassName:@"Notifications"];
            [deleteGroupNotification setObject:[PFUser currentUser] forKey:@"fromUser"];
            [deleteGroupNotification setObject:groupUser[@"user"] forKey:@"toUser"];
            [deleteGroupNotification setObject:note forKey:@"note"];
            [deleteGroupNotification setValue:[NSNumber numberWithBool:NO] forKey:@"read"];
            [deleteGroupNotification saveEventually];

        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)nameChanged:(id)sender {
    if ([self.nameLabel.text isEqualToString:self.backupName]) {
        //
    } else {
        NSString *oldname = self.backupName;
        self.navigationItem.title = self.nameLabel.text;
        [groupTabBarController.group setObject:self.nameLabel.text forKey:@"name"];
        [groupTabBarController.group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                for (PFObject *groupUser in groupTabBarController.groupUsers) {
                    NSString *note = [NSString stringWithFormat: @"'%@' group's name to '%@'", oldname, self.nameLabel.text];
                    
                    PFObject *deleteGroupNotification = [PFObject objectWithClassName:@"Notifications"];
                    [deleteGroupNotification setObject:[PFUser currentUser] forKey:@"fromUser"];
                    [deleteGroupNotification setObject:groupUser[@"user"] forKey:@"toUser"];
                    [deleteGroupNotification setObject:note forKey:@"note"];
                    [deleteGroupNotification setValue:[NSNumber numberWithBool:NO] forKey:@"read"];
                    [deleteGroupNotification saveEventually];
                
                }
            } else{
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"The Internet connection appears to be offline. Please try it again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [errorAlertView show];
            }
        }];
        
        self.backupName = self.nameLabel.text;
    }
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showMembers"]) {
        MembersTableViewController *membersViewController = segue.destinationViewController;
        membersViewController.groupUsers = groupTabBarController.groupUsers;
        membersViewController.group = groupTabBarController.group;
    }
}

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
                            NSString *string3 = @"group";
                            NSString *note = [NSString stringWithFormat: @"'%@' invited you to join '%@' %@", string1, string2, string3];
                            
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
