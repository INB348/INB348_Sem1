//
//  LogInViewController.h
//  INB348
//
//  Created by nOrJ on 10/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogInViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *txt_Email;
@property (nonatomic, strong) IBOutlet UITextField *txt_Password;


-(IBAction)logInPressed:(id)sender;

@end
