//
//  WinPropertyFeeVC.h
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/26.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WinPropertyFeeVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *winFee;
@property (weak, nonatomic) IBOutlet UILabel *todayGain;
@property (weak, nonatomic) IBOutlet UITableView *advertisingTableView;
@end
