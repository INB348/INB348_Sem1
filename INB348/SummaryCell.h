//
//  SummaryCell.h
//  INB348
//
//  Created by Kristian M Matzen on 08/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SummaryCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *oldBalance;
@property (nonatomic, weak) IBOutlet UILabel *payed;
@property (nonatomic, weak) IBOutlet UILabel *used;
@property (nonatomic, weak) IBOutlet UILabel *updatedBalance;
@end
