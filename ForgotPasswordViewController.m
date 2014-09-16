//
//  ForgotPasswordViewController.m
//  INB348
//
//  Created by nOrJ on 10/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import <Parse/Parse.h>

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController
@synthesize txt_RecoveryEmail = _txt_RecoveryEmail;


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.txt_RecoveryEmail.delegate = self;
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
    [self.txt_RecoveryEmail resignFirstResponder];
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
    self.txt_RecoveryEmail = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)resetPasswordPressed:(id)sender
{
    BOOL isValidEmail = [self NSStringIsValidEmail: _txt_RecoveryEmail.text];
    
    if (isValidEmail) {
        [PFUser requestPasswordResetForEmailInBackground:self.txt_RecoveryEmail.text block:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No account found with that email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [errorAlertView show];
            } else {
                UIAlertView *sendingEmailSuccessful = [[UIAlertView alloc] initWithTitle:@"Notification" message:@"We have sent an email to the address.\nRespond to it within an hour to reactivate your account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [sendingEmailSuccessful show];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    } else {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You enter email address in wrong format. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorAlertView show];
    }

    
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if (buttonIndex == [alertView cancelButtonIndex]){
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }
//}

-(BOOL) NSStringIsValidEmail:(NSString *)checkEmail
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkEmail];
}

@end
