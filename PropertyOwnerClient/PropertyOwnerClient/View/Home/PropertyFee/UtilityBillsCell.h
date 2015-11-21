//
//  UtilityBillsCell.h
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/27.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilityBills.h"
@protocol PassRegValueDelegate<NSObject>
/**
 *给注册页面传值
 */
-(void)passRegValues:(NSMutableDictionary*)dict;
@end

@interface UtilityBillsCell : UITableViewCell<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *payArrays;
    NSString *propertyId;
}
@property (weak, nonatomic) IBOutlet UIImageView *angleView;

///1.定义向注册页面传值的委托变量
@property (weak,nonatomic) id <PassRegValueDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *month;
@property (weak, nonatomic) IBOutlet UILabel *year;
@property (weak, nonatomic) IBOutlet UILabel *sum;
@property (weak, nonatomic) IBOutlet UILabel *unpaid;

@property (weak, nonatomic) IBOutlet UIView *submitBillsView;


@property (weak, nonatomic) IBOutlet UIView *extensionView;
@property (weak, nonatomic) IBOutlet UITableView *paymentRecordsTableView;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

- (IBAction)submitBills:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *inputMoney;


-(void)settingData:(UtilityBills *)utilityBills;
+ (instancetype)cellWithTableView:(UITableView *)tableView;

-(void)reloadTableViewWith:(NSString *)intputPropertyId;
@end
