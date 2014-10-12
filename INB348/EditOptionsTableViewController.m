//
//  EditOptionsTableViewController.m
//  INB348
//
//  Created by Kristian M Matzen on 11/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import "EditOptionsTableViewController.h"

@interface EditOptionsTableViewController ()

@end

@implementation EditOptionsTableViewController
@synthesize delegate;
NSString *viewControllerTitle;

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setExpenseParticipatorIndexes:(NSMutableArray *)indexes{
    if([viewControllerTitle isEqualToString:@"WhoPaid"]){
        [self.delegate expensePayerIndexes:indexes];
    } else {
       [self.delegate expenseUserIndexes:indexes];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    EditExpenseParticipatorsTableViewController *destViewController = (EditExpenseParticipatorsTableViewController *) [(UINavigationController *)segue.destinationViewController topViewController];
    destViewController.groupUsers = self.groupUsers;
    [destViewController setDelegate:self];
    
    if ([segue.identifier isEqualToString:@"editWhoPaid"]) {
        destViewController.title = @"Who Paid";
        viewControllerTitle = @"WhoPaid";
        destViewController.indexes=[self.delegate expensePayerIndexes];
        
    }
    if ([segue.identifier isEqualToString:@"editForWhom"]) {
        destViewController.title = @"For Whom";
        viewControllerTitle = @"ForWhom";
        destViewController.indexes=[self.delegate expenseUserIndexes];
    }
}


@end
