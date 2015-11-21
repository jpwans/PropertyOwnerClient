//
//  AdvTableViewCell.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/6/10.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "AdvTableViewCell.h"
#import "AngleCircleView.h"
@implementation AdvTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _isLookView.hidden  =YES;
    //    _infoView.layer.masksToBounds = YES;
    //    _infoView.layer.cornerRadius = 6.0;
    //    _infoView.layer.borderWidth = 1.0;
    //    _infoView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    //
    //    _titleView.backgroundColor  = BACKGROUND_COLOR;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)settingData:(Advertising *)advertising{
    _advTitle.text = advertising.advertiseName;
    NSString *urlStr  = [NSString stringWithFormat:@"%@%@",URL_QINIU,advertising.logoImage];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [_advImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"aio_image_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    int todayStatus =[advertising.todayStatus intValue];
    _isLookView.hidden = todayStatus;
        if (!todayStatus ==1) {
    AngleCircleView  *angleCircleView = [[AngleCircleView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-advWidth/3,0 , advWidth/3, advWidth/3)];
            angleCircleView.alpha = 0.7;
    angleCircleView.backgroundColor = [UIColor clearColor];
    [self addSubview:angleCircleView];
    UILabel *moneyLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, advWidth/3, 16)];
    moneyLable.text = [NSString stringWithFormat:@"+%@",advertising.ownerProfit];

    moneyLable.font = SystemFont(9);
    moneyLable.textAlignment=NSTextAlignmentCenter;

    [angleCircleView addSubview:moneyLable];

    
        }

    
}
+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"status";
    AdvTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AdvTableViewCell" owner:nil options:nil] lastObject];
    }
    return cell;
}
@end
