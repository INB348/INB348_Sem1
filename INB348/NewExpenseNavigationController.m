//
//  NewExpenseNavigationController.m
//  INB348
//
//  Created by Kristian Matzen on 18/09/2014.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "NewExpenseNavigationController.h"

@interface NewExpenseNavigationController ()

@end

@implementation NewExpenseNavigationController
@synthesize groupUsers;
@synthesize group;
@synthesize delegate;

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
    self.expenseParticipators = [NSMutableArray array];
    for (PFObject *groupUser in self.groupUsers) {
        PFObject *expenseParticipator = [PFObject objectWithClassName:@"ExpenseParticipator"];
        [expenseParticipator setObject:groupUser forKey:@"user"];
        [expenseParticipator setValue:@0 forKey:@"payment"];
        [expenseParticipator setValue:@0 forKey:@"usage"];
        [self.expenseParticipators addObject:expenseParticipator];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
