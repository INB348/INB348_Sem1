//
//  SignUpViewController.h
//  INB348
//
//  Created by nOrJ on 10/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *txt_NewEmail;
@property (nonatomic, strong) IBOutlet UITextField *txt_NewPassword;
@property (nonatomic, strong) IBOutlet UITextField *txt_ReTypePassword;

-(IBAction)signUpPressed:(id)sender;

@end
