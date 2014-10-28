//
//  AccountSettingsTableViewController.m
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "AccountSettingsTableViewController.h"
#import "SWRevealViewController.h"

@interface AccountSettingsTableViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@end

@implementation AccountSettingsTableViewController
@synthesize img_Profile = _img_Profile,
txt_NewName = _txt_NewName,
txt_NewPassword = _txt_NewPassword,
txt_ReTypePassword = _txt_ReTypePassword;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customSetup];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.txt_NewName.delegate = self;
    self.txt_NewPassword.delegate = self;
    self.txt_ReTypePassword.delegate = self;
    
    // Fetch the devices from persistent data store
    self.txt_NewName.text = [[PFUser currentUser] objectForKey:@"name"];
    
    /* Profile Image Format */
    PFFile *thumbnail = [[PFUser currentUser] objectForKey:@"profilePic"];
    self.img_Profile.image = [UIImage imageNamed:@"pill.png"];
    
    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        // Now that the data is fetched, update the cell's image property.
        if(!error) {
            self.img_Profile.image = [UIImage imageWithData:data];
        } else {
            self.img_Profile.image = [UIImage imageNamed:@"pill.png"];
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
    [self.txt_NewName resignFirstResponder];
    [self.txt_NewPassword resignFirstResponder];
    [self.txt_ReTypePassword resignFirstResponder];
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
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
/* end */

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

-(IBAction)save:(id)sender {
    //Profile Picture
    NSData *imageData = UIImagePNGRepresentation(self.img_Profile.image);
    NSString *imageName = [NSString stringWithFormat:@"%@_ProfilePhoto", self.txt_NewName.text];
    PFFile *imageFile = [PFFile fileWithName:imageName data:imageData];
    
    PFQuery *updateCurrentUserInfo = [PFUser query];
    [updateCurrentUserInfo whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    
    if (![self.txt_ReTypePassword.text isEqualToString:self.txt_NewPassword.text]) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your passwords do not match. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [errorAlertView show];
        
    } else {
        
        // Show progress
        hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.labelText = @"Uploading";
        [hud show:YES];
        
        // myProgressTask uses the HUD instance to update progress
        [hud showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
        
        [updateCurrentUserInfo getFirstObjectInBackgroundWithBlock:^(PFObject *currentUserInfo, NSError *error) {
            
            if(!error) {
                
                currentUserInfo[@"name"] = self.txt_NewName.text;
                [PFUser currentUser].password = self.txt_NewPassword.text;
                [[PFUser currentUser] saveInBackground];
                
                currentUserInfo[@"profilePic"] = imageFile;
                [currentUserInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (!error) {
                        [hud hide:YES];
                        
                        // Show success message
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update Complete" message:@"Successfully updated your account information" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                        
                        // Dismiss the controller
                        [self performSegueWithIdentifier:@"BackToGroupView" sender:self];
                        
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update Failure" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                        
                    }
                    
                }];
                
            } else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update Failure" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
            }
        }];
    }
}

- (void)myProgressTask {
    // This just increases the progress indicator in a loop
    float progress = 0.0f;
    while (progress < 1.0f) {
        progress += 0.01f;
        hud.progress = progress;
        usleep(50000);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
