//
//  HistoryCell.h
//  INB348
//
//  Created by Kristian M Matzen on 28/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *balanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *createdAtLabel;
@end
