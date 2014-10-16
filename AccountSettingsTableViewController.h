//
//  AccountSettingsTableViewController.h
//  INB348
//
//  Created by nOrJ on 4/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountSettingsTableViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>


@property (strong, nonatomic) IBOutlet UIImageView *img_Profile;
@property (nonatomic, strong) IBOutlet UITextField *txt_NewPassword;
@property (nonatomic, strong) IBOutlet UITextField *txt_ReTypePassword;
@property (nonatomic, strong) IBOutlet UITextField *txt_NewName;

- (IBAction)selectPhoto:(UIButton *)sender;

-(IBAction)save:(id)sender;

@end
