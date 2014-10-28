//
//  NumberFormatterSingleton.h
//  INB348
//
//  Created by Kristian M Matzen on 28/10/14.
//  Copyright (c) 2014 nOrJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NumberFormatterSingleton : NSObject
+ (id)sharedMyNumberFormatterSingleton;
- (NSNumberFormatter *)getCurrencyNumberFormatter;
- (NSNumberFormatter *)getNumberFormatter;
@end
