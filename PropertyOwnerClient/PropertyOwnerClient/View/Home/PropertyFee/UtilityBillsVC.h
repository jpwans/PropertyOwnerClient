//
//  UtilityBillsVC.h
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/27.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UtilityBillsVC : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *earnFee;
@property (weak, nonatomic) IBOutlet UILabel *payFee;
@property (weak, nonatomic) IBOutlet UITableView *UtilityBillsTableView;

@end
