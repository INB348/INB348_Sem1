//
//  NewExpenseDetailsViewController.m
//  INB348
//
//  Created by Kristian Matzen on 18/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "NewExpenseDetailsViewController.h"
#import "ColorSingleton.h"

@interface NewExpenseDetailsViewController ()
@property (nonatomic, assign) id currentResponder;
@end

@implementation NewExpenseDetailsViewController
NewExpenseNavigationController *navigationController;
ColorSingleton *colorSingleton;

#pragma mark - Setup
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setScrollView
{
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 700)];
}

- (void)setDescriptionTextViewBorders
{
    self.descriptionTextView.layer.borderWidth = 2.0f;
    self.descriptionTextView.layer.borderColor = [[colorSingleton getLightGreyColor] CGColor];
    self.descriptionTextView.layer.cornerRadius = 8;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setDescriptionTextViewBorders];
    navigationController = (NewExpenseNavigationController *)[self navigationController];
    colorSingleton = [ColorSingleton sharedColorSingleton];
    
    [self setUpTap];
    [self setScrollView];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.nameTextField setTintColor:[colorSingleton getBlueColor]];
    [self.amountTextField setTintColor:[colorSingleton getBlueColor]];
    [self.descriptionTextView setTintColor:[colorSingleton getBlueColor]];
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showWhoPaid"]) {
        navigationController.name = self.nameTextField.text;
        navigationController.amount = @([self.amountTextField.text doubleValue]);
        navigationController.comment = self.descriptionTextView.text;
        navigationController.date = self.datePicker.date;
    }
}

#pragma mark - Buttons
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showOkAlertButton:(NSString *)message {
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [errorAlertView show];
}

- (IBAction)next:(id)sender {
    if(![self.nameTextField.text isEqualToString:@""]){
        if(![self.amountTextField.text isEqualToString:@""]){
            [self performSegueWithIdentifier:@"showWhoPaid" sender:self];
        }else {
            NSLog(@"Must set an Amount");
            [self showOkAlertButton:@"Amount can't be blank.\nPlease try again."];
        }
    }else {
        NSLog(@"Must choose a Name");
        [self showOkAlertButton:@"Name can't be blank.\nPlease try again."];
    }
}
@end
