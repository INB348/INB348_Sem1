//
//  LogInViewController.m
//  INB348
//
//  Created by nOrJ on 10/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "LogInViewController.h"
#import <Parse/Parse.h>

@interface LogInViewController ()

@end

@implementation LogInViewController

@synthesize txt_Email = _txt_Email, txt_Password = _txt_Password;


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Default email and password for testing
    self.txt_Email.text = @"tranminhphat1011@gmail.com";
    self.txt_Password.text = @"123";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    self.txt_Email = nil;
    self.txt_Password = nil;
}


#pragma mark IB Actions

//Login button pressed
-(IBAction)logInPressed:(id)sender
{
    [PFUser logInWithUsernameInBackground:self.txt_Email.text password:self.txt_Password.text block:^(PFUser *user, NSError *error) {
        if (user)
        {
            // go to the Group Page if log in successful
            [self performSegueWithIdentifier:@"LogInSuccessful" sender:self];
        } else {
            //Something bad has ocurred
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid email or password.\nPlease try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
        }
    }];
}

@end
