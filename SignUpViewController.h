//
//  SignUpViewController.h
//  INB348
//
//  Created by nOrJ on 10/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface SignUpViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *hud;
}


@property (nonatomic, strong) IBOutlet UITextField *txt_NewEmail;
@property (nonatomic, strong) IBOutlet UITextField *txt_NewPassword;
@property (nonatomic, strong) IBOutlet UITextField *txt_ReTypePassword;
@property (nonatomic, strong) IBOutlet UITextField *txt_Name;
@property (strong, nonatomic) IBOutlet UIImageView *img_Profile;

- (IBAction)selectPhoto:(UIButton *)sender;

-(IBAction)signUpPressed:(id)sender;

@end
