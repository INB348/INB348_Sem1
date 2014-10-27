//
//  NewExpenseDetailsViewController.m
//  INB348
//
//  Created by Kristian Matzen on 18/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "NewExpenseDetailsViewController.h"

@interface NewExpenseDetailsViewController ()
@property (nonatomic, assign) id currentResponder;
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
    self.descriptionTextView.layer.borderWidth = 5.0f;
    self.descriptionTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.descriptionTextView.layer.cornerRadius = 8;
    navigationController = (NewExpenseNavigationController *)[self navigationController];
    
    [self setUpTap];
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 700)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Highlight and Tap
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentResponder = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.currentResponder = nil;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    self.currentResponder = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.currentResponder = nil;
}

- (void)resignOnTap:(id)iSender {
    [self.currentResponder resignFirstResponder];
}

- (void)setUpTap
{
    //Set Textfield delegates
    self.amountTextField.delegate = self;
    self.nameTextField.delegate = self;
    self.descriptionTextView.delegate = self;
    
    //Setup tap
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];

}

#pragma mark - 'Done' out of Keyboard
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - Keyboard pushes TextField Up


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showWhoPaid"]) {
        if(![self.nameTextField.text isEqualToString:@""]){
            navigationController.name = self.nameTextField.text;
        }else {
            NSLog(@"Must choose a Name");
        }
        if(![self.amountTextField.text isEqualToString:@""]){
           navigationController.amount = @([self.amountTextField.text doubleValue]);
        }else {
            NSLog(@"Must set an Amount");
        }
        navigationController.comment = self.descriptionTextView.text;
        navigationController.date = self.datePicker.date;
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
