//
//  RoomTableViewCell.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/7/10.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "RoomTableViewCell.h"

@implementation RoomTableViewCell

- (void)awakeFromNib {
    // Initialization code
    CALayer *bottomBorder = [CALayer layer];
        CGFloat  hight = self.frame.size.height - 1;
    bottomBorder.frame = CGRectMake(0.0f, hight, SCREEN_WIDTH, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:227.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0].CGColor;
    [self.layer addSublayer:bottomBorder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)settingData:(SwitchRoom *)switchRoom{
    _community.text = switchRoom.community;
    _address.text = [NSString stringWithFormat:@"%@/%@/%@",switchRoom.buildingNo,switchRoom.unitNo,switchRoom.roomNo];
    _relationship.text = [switchRoom.roleType intValue]==10?@"业主":@"关联用户";
    _checkView.hidden =  !switchRoom.isCheck;

}
+ (instancetype)cellWithTableView:(UITableView *)tableView{

    static NSString *ID = @"status";
    RoomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RoomTableViewCell" owner:nil options:nil] lastObject];
    }
    return cell;
}
@end
