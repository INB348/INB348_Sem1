//
//  ForgotPasswordViewController.h
//  INB348
//
//  Created by nOrJ on 10/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *txt_RecoveryEmail;

-(IBAction)resetPasswordPressed:(id)sender;


@end
