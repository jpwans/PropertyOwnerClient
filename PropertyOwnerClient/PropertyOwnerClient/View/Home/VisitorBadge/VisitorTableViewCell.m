//
//  VisitorTableViewCell.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/18.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "VisitorTableViewCell.h"
#import "VisitorCard.h"
@implementation VisitorTableViewCell

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}



-(void)settingData:(VisitorCard *)visitorCard{
    
    self.cellView.layer.masksToBounds = YES;
    self.cellView.layer.cornerRadius = 6.0;
    self.cellView.layer.borderWidth = 1.0;
    self.cellView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.name .text= visitorCard.name;
    self.phone.text =visitorCard.phone;
    NSString *visitorState = @"";
    int state = [[NSString stringWithFormat:@"%@",visitorCard.visitState] intValue];
    NSLog(@"%d",state);
    NSString *time = @"";
    NSString *timeName = @"";
    NSLog(@"%@",visitorCard.createDate);
    switch (state) {
        case 0:
            visitorState =@"未拜访";
            time = [visitorCard.createDate substringToIndex:16];
            timeName =@"创建：";
            break;
        case 1 :
            visitorState =@"已拜访";
            time = [visitorCard.visitTime substringToIndex:16];
               timeName =@"来访：";
            break;
        case 2:
            visitorState =@"二维码已过期";
             time = [visitorCard.createDate substringToIndex:16];
                        timeName =@"创建：";
            break;
        case 3:
            visitorState =@"未发送";
            time = [visitorCard.createDate substringToIndex:16];
                        timeName =@"创建：";
            break;
        default:
            visitorState  = @"未知";
                        timeName =@"创建：";
            time = [visitorCard.createDate substringToIndex:16];
            break;
    }
    _countdown.hidden =  state==1?YES:NO;
    self.visitorTimeState.text = timeName;
    self.visitorTime.text = time;
    
    self.visitorState.text = visitorState;
    NSString * imageName = [visitorCard.sex intValue]==1?@"icon_male":@"icon_female";
    self.sexImage.image = [UIImage imageNamed:imageName];
    
    NSString *carImageName = [visitorCard.isDrive intValue]==1?@"icon_car":@"";
    self.carImage.image = [UIImage imageNamed:carImageName];
    
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"] ];
    
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSDate*inputDate = [inputFormatter dateFromString:visitorCard.createDate];
    NSString * since = [VisitorTableViewCell compareCurrentTime:[inputDate dateByAddingTimeInterval:259200.0f]];
    self.countdown.text = [NSString stringWithFormat:@"%@过期",since];
  
}

+(NSString *) compareCurrentTime:(NSDate*) compareDate
{
    NSTimeInterval  timeInterval = [compareDate timeIntervalSinceNow];
//    timeInterval = -timeInterval;
    long temp = 0;
    NSString *result;
    if(timeInterval <=0){
     result = [NSString stringWithFormat:@"二维码已"];
    }else
    if (timeInterval < 60&&timeInterval>0) {
        result = [NSString stringWithFormat:@"马上"];
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%ld分后",temp];
    }
    
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%ld小后",temp];
    }
    
    else if((temp = temp/24) <30){
        result = [NSString stringWithFormat:@"%ld天后",temp];
    }
    
    else if((temp = temp/30) <12){
        result = [NSString stringWithFormat:@"%ld月后",temp];
    }
    else{
        temp = temp/12;
        result = [NSString stringWithFormat:@"%ld年后",temp];
    }
    
    return  result;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"status";
    VisitorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"VisitorTableViewCell" owner:nil options:nil] lastObject];
    }
    return cell;
}
@end
