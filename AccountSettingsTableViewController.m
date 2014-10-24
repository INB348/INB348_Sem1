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
    
    self.txt_NewName.text = [[PFUser currentUser] objectForKey:@"name"];
    
    /* Profile Image Format */
    // Configure the cell
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
    self.img_Profile.image = chosenImage;
    
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
//    // Create a pointer to an object of class Point with id dlkj83d
//    PFObject *point = [PFObject objectWithoutDataWithClassName:@"User" objectId:@"8y5nycYFuk"];
//    
//    // Set a new value on quantity
//    [point setObject:self.txt_NewName.text forKey:@"name"];
//    
//    // Save
//    [point save];

    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:[PFUser currentUser].objectId block:^(PFObject *gameScore, NSError *error) {
        
        // Now let's update it with some new data. In this case, only cheatMode and score
        // will get sent to the cloud. playerName hasn't changed.
        gameScore[@"name"] = self.txt_NewName.text;
        [gameScore saveInBackground];
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
