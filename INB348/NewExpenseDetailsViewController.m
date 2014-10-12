//
//  NewExpenseDetailsViewController.m
//  INB348
//
//  Created by Kristian Matzen on 18/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "NewExpenseDetailsViewController.h"

@interface NewExpenseDetailsViewController ()

@end

@implementation NewExpenseDetailsViewController
NewExpenseNavigationController *navigationController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.descriptionTextField.layer.borderWidth = 5.0f;
    self.descriptionTextField.layer.borderColor = [[UIColor grayColor] CGColor];
    self.descriptionTextField.layer.cornerRadius = 8;
    navigationController = (NewExpenseNavigationController *)[self navigationController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showWhoPaid"]) {
        navigationController.name = self.nameTextField.text;
        NSLog(@"%@",self.descriptionTextField.text);
        navigationController.comment = self.descriptionTextField.text;
        navigationController.amount = @([self.amountTextField.text intValue]);
        navigationController.date = self.datePicker.date;
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
