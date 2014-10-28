//
//  SignUpViewController.m
//  INB348
//
//  Created by nOrJ on 10/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "SignUpViewController.h"
#import "ForgotPasswordViewController.h"
#import <Parse/Parse.h>

@interface SignUpViewController ()
@end

@implementation SignUpViewController

@synthesize txt_NewEmail = _txt_NewEmail,
txt_NewPassword = _txt_NewPassword,
txt_ReTypePassword = _txt_ReTypePassword,
img_Profile = _img_Profile,
txt_Name = _txt_Name;



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Default new Email and Password for testing
    self.txt_NewEmail.delegate = self;
    self.txt_NewPassword.delegate = self;
    self.txt_ReTypePassword.delegate = self;
    self.txt_Name.delegate = self;
    
    /* Profile Image Format */
    self.img_Profile.image = [UIImage imageNamed:@"person_grey.jpg"];
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

/** Dismiss keyboard */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.txt_NewEmail resignFirstResponder];
    [self.txt_NewPassword resignFirstResponder];
    [self.txt_ReTypePassword resignFirstResponder];
    [self.txt_Name resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField) {
        [textField resignFirstResponder];
    }
    
    return NO;
}
/* end */


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.txt_NewEmail= nil;
    self.txt_NewPassword = nil;
    self.txt_ReTypePassword = nil;
    self.txt_Name = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Sign Up Button pressed
-(IBAction)signUpPressed:(id)sender {
    BOOL isValidEmail = [self NSStringIsValidEmail: _txt_NewEmail.text];
    
    if (isValidEmail) {
        if (![self.txt_ReTypePassword.text isEqualToString:self.txt_NewPassword.text]) {
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your passwords do not match. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
            
        } else {
            PFUser *user = [PFUser user];
            user.username = self.txt_NewEmail.text;
            user.password = self.txt_NewPassword.text;
            
            // Show progress
            hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:hud];
            hud.mode = MBProgressHUDModeAnnularDeterminate;
            hud.labelText = @"Uploading";
            [hud show:YES];
            
            // myProgressTask uses the HUD instance to update progress
            [hud showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    
                    //The registration was succesful, go to the wall
                    NSData *imageData = UIImagePNGRepresentation(self.img_Profile.image);
                    
                    NSString *imageName = [NSString stringWithFormat:@"%@_ProfilePhoto", self.txt_Name.text];
                    PFFile *imageFile = [PFFile fileWithName:imageName data:imageData];
                    [imageFile saveInBackground];
                    
                    PFUser *user = [PFUser currentUser];
                    [user setObject:self.txt_Name.text forKey:@"name"];
                    [user setObject:imageFile forKey:@"profilePic"];
                    
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [hud hide:YES];
                        if (succeeded) {
                            [self performSegueWithIdentifier:@"SignUpSuccessful" sender:self];
                            
                            UIAlertView *welcomeView = [[UIAlertView alloc] initWithTitle:@"Welcome" message:@"You've successfully signed up to WhoPaysNext :)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            [welcomeView show];
                        }
                    }];
                    
                } else {
                    //Something bad has ocurred
                    NSString *errorText = [NSString stringWithFormat: @"Sorry, it looks like '%@' belongs to an existing account.\nWould you like to reset password?", self.txt_NewEmail.text];
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorText delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                    [errorAlertView show];
                }
            }];
        }
    } else {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You enter email address in wrong format. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorAlertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]){
        //cancel clicked ...do your action
    }else{
        ForgotPasswordViewController *forgotPassword = [self.storyboard instantiateViewControllerWithIdentifier:@"ForgotPassword"];
        [self.navigationController pushViewController:forgotPassword  animated:YES ];
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

- (void)myProgressTask {
    // This just increases the progress indicator in a loop
    float progress = 0.0f;
    while (progress < 1.0f) {
        progress += 0.01f;
        hud.progress = progress;
        usleep(50000);
    }
}

//    - (BOOL)passwordcheck:(NSString *)password {
//
//        // 1. Upper case.
//        if (![[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[password characterAtIndex:0]])
//            return NO;
//
//        // 2. Length.
//        if ([password length] < 6)
//            return NO;
//
//        // 3. Special characters.
//        // Change the specialCharacters string to whatever matches your requirements.
//        NSString *specialCharacters = @"!#€%&/()[]=?$§*'";
//        if ([[password componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:specialCharacters]] count] < 2)
//            return NO;
//
//        // 4. Numbers.
//        if ([[password componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]] count] < 2)
//            return NO;
//
//        return YES;
//    }

@end
