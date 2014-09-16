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
            txt_ReTypePassword = _txt_ReTypePassword;


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Default new Email and Password for testing
    self.txt_NewEmail.delegate = self;
    self.txt_NewPassword.delegate = self;
    self.txt_ReTypePassword.delegate = self;
}


/** Move the UIView up when the keyboard is hiding an object on the screen */
- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -5.0f;  //set the -35.0f to your required value
        self.view.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 63.0f;
        self.view.frame = f;
    }];
}
/* end */


/** Dismiss keyboard */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.txt_NewEmail resignFirstResponder];
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


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.txt_NewEmail= nil;
    self.txt_NewPassword = nil;
    self.txt_ReTypePassword = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Sign Up Button pressed
-(IBAction)signUpPressed:(id)sender
{
    BOOL isValidEmail = [self NSStringIsValidEmail: _txt_NewEmail.text];
    
    if (isValidEmail) {
        if (![self.txt_ReTypePassword.text isEqualToString:self.txt_NewPassword.text]) {
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your passwords do not match. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];

        } else {
            PFUser *user = [PFUser user];
            user.username = self.txt_NewEmail.text;
            user.password = self.txt_NewPassword.text;
            user.email = self.txt_NewEmail.text;
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    //The registration was succesful, go to the wall
                    [self performSegueWithIdentifier:@"SignUpSuccessful" sender:self];
                    
                } else {
                    //Something bad has ocurred
                    NSString *errorText = [NSString stringWithFormat: @"Sorry, it looks like '%@' belongs to an existing account.\nWould you like to reset password?", self.txt_NewEmail.text];
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorText delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                    [errorAlertView show];
                }
            }];
        }
    } else {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You enter email address in wrong format. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorAlertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        //cancel clicked ...do your action
    }else{
        ForgotPasswordViewController *forgotPassword = [self.storyboard instantiateViewControllerWithIdentifier:@"ForgotPassword"];
        [self.navigationController pushViewController:forgotPassword  animated:YES ];
    }
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkEmail
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkEmail];
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
