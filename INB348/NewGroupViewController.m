//
//  NewGroupViewController.m
//  INB348
//
//  Created by Kristian M Matzen on 17/09/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "NewGroupViewController.h"


@interface NewGroupViewController ()

@end

@implementation NewGroupViewController

@synthesize img_Profile = _img_Profile,
            nameTextField = _nameTextField;


//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameTextField.delegate = self;
    /* Profile Image Format */
    self.img_Profile.image = [UIImage imageNamed:@"pill.png"];
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
    [self.nameTextField resignFirstResponder];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender {
    if ([self.nameTextField.text length] != 0) {
        // Create a new Group and set name
        PFObject *group= [PFObject objectWithClassName:@"Group"];
        [group setObject:self.nameTextField.text forKey:@"name"];
        
        
        //Profile Picture
        NSData *imageData = UIImagePNGRepresentation(self.img_Profile.image);
        NSString *imageName = [NSString stringWithFormat:@"%@_GroupPhoto", self.nameTextField.text];
        PFFile *imageFile = [PFFile fileWithName:imageName data:imageData];
        [group setObject:imageFile forKey:@"groupPic"];
        
        // Show progress
        hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.labelText = @"Uploading";
        [hud show:YES];
        
        // myProgressTask uses the HUD instance to update progress
        [hud showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
        
        // Upload recipe to Parse
        [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if(succeeded) {
                [hud hide:YES];
                // Show success message
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Complete" message:@"Successfully created new group" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
                // Notify table view to reload the recipes from Parse cloud
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTable" object:self];
                
                // Create a new UserGroup relation
                PFObject *userGroup= [PFObject objectWithClassName:@"UserGroup"];
                [userGroup setObject:[PFUser currentUser] forKey:@"user"];
                [userGroup setObject:group forKey:@"group"];
                
                //Set default balance of 0
                userGroup[@"balance"] = @0;
                userGroup[@"accepted"] = @YES;
                
                //Save
                [userGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(succeeded){
                        [self.delegate refresh];
                        
                        // Dismiss the controller
                        [self dismissViewControllerAnimated:YES completion:nil];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create Relation Failure" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                }];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Please input the Group name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
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

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
};

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
