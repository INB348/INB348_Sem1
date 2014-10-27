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

-(void)setExpenseParticipatorIndexes:(NSMutableDictionary *)indexAndMultipliers{
    if([viewControllerTitle isEqualToString:@"WhoPaid"]){
        [self.delegate expensePayerIndexes:indexAndMultipliers];
    } else {
        [self.delegate expenseUserIndexes:indexAndMultipliers];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    EditExpenseParticipatorsTableViewController *destViewController = (EditExpenseParticipatorsTableViewController *) [(UINavigationController *)segue.destinationViewController topViewController];
    destViewController.groupUsers = self.groupUsers;
    [destViewController setDelegate:self];
    
    if ([segue.identifier isEqualToString:@"editWhoPaid"]) {
        destViewController.title = @"Who Paid";
        viewControllerTitle = @"WhoPaid";
        destViewController.keysAndMultipliers = [self.delegate paymentKeysAndMultipliers];
//        NSArray *keys = [[self.delegate paymentKeysAndMultipliers] allKeys];
//        NSMutableArray *keysNumbers = [NSMutableArray array];
//        for (NSString *key in keys) {
//            [keysNumbers addObject:[NSNumber numberWithInteger:[key integerValue]]];
//        }
//        destViewController.indexes = keysNumbers;
        
    }
    if ([segue.identifier isEqualToString:@"editForWhom"]) {
        destViewController.title = @"For Whom";
        viewControllerTitle = @"ForWhom";
        destViewController.keysAndMultipliers = [self.delegate usageKeysAndMultipliers];
//        NSArray *keys = [[self.delegate usageKeysAndMultipliers] allKeys];
//        NSMutableArray *keysNumbers = [NSMutableArray array];
//        for (NSString *key in keys) {
//            [keysNumbers addObject:[NSNumber numberWithInteger:[key integerValue]]];
//        }
//        destViewController.indexes = keysNumbers;
    }
}


@end
