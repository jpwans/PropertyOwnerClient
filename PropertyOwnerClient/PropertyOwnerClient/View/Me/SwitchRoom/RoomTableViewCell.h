//
//  RoomTableViewCell.h
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/7/10.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchRoom.h"
@interface RoomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *community;
//@property (weak, nonatomic) IBOutlet UILabel *roomNo;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UIImageView *checkView;

@property (weak, nonatomic) IBOutlet UILabel *relationship;
-(void)settingData:(SwitchRoom *)switchRoom;
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
