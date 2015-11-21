//
//  VisitorTableViewCell.h
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/18.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VisitorCard;
@interface VisitorTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UILabel *visitorState;
@property (weak, nonatomic) IBOutlet UILabel *carNum;
@property (weak, nonatomic) IBOutlet UIImageView *sexImage;
@property (weak, nonatomic) IBOutlet UIImageView *carImage;
@property (weak, nonatomic) IBOutlet UILabel *countdown;
@property (weak, nonatomic) IBOutlet UIView *cellView;
@property (weak, nonatomic) IBOutlet UILabel *visitorTimeState;
@property (weak, nonatomic) IBOutlet UILabel *visitorTime;


-(void)settingData:(VisitorCard *)visitorCard;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
