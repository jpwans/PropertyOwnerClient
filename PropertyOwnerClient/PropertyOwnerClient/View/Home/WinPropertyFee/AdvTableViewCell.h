//
//  AdvTableViewCell.h
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/6/10.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Advertising.h"
#import "AngleCircleView.h"
@interface AdvTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *advTitle;
@property (weak, nonatomic) IBOutlet UIImageView *advImageView;
//@property (weak, nonatomic) IBOutlet UIView *isLookView;
@property (weak, nonatomic) IBOutlet UILabel *advFee;
@property (weak, nonatomic) IBOutlet UIView *infoView;

@property (weak, nonatomic) IBOutlet AngleCircleView *isLookView;

-(void)settingData:(Advertising *)advertising;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
