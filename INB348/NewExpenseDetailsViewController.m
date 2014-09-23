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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showWhoPaid"]) {
        NewExpenseWhoPaidTableViewController *destViewController = segue.destinationViewController;
        destViewController.name = self.nameTextField.text;
        destViewController.amount = @([self.amountTextField.text intValue]);
        destViewController.date = self.datePicker.date;
        destViewController.groupUsers=self.groupUsers;
        destViewController.group = self.group;
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
