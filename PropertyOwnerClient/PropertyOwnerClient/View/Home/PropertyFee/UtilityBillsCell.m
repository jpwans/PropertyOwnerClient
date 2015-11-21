//
//  UtilityBillsCell.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/27.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "UtilityBillsCell.h"
#import "PayRecordsCell.h"
#import "UtilityBills.h"
@implementation UtilityBillsCell

- (void)awakeFromNib {
    // Initialization code
    _inputMoney.keyboardType = UIKeyboardTypeNumberPad;
    _paymentRecordsTableView.dataSource =self;
    _paymentRecordsTableView.delegate =self;
    _submitBtn.backgroundColor = BACKGROUND_COLOR;
    
    _submitBtn.layer.masksToBounds = YES;
    _submitBtn.layer.cornerRadius = 6.0;
    _submitBtn.layer.borderWidth = 1.0;
    _submitBtn.layer.borderColor = [[UIColor clearColor] CGColor];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}




- (IBAction)submitBills:(UIButton *)sender {
    if ([_inputMoney.text floatValue]<50) {
                 [self makeToast:@"输入的金额不能小于50" duration:1.5f position:@"center"];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:_inputMoney.text forKey:@"gold"];
    [dic setValue:propertyId forKey:@"goldId"];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:dic];
    
    NSMutableDictionary *payList =[[NSMutableDictionary alloc] init];
    [payList setValue:array forKey:@"payList"];
    
    NSString *str =  [[PublicClass sharedManager] DataTOjsonString:payList];
    NSMutableDictionary *part =[[NSMutableDictionary alloc] init];
    [part setValue:str forKey:@"costList"];
    [part setObject:[[Config Instance] getRoomId] forKey:@"roomId"];
    NSLog(@"%@",part);
//    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
//    [manager POST:API_BASE_URL_STRING(URL_ADDPROPERTYFEE) parameters:part success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *dictionary= responseObject;
//        NSLog(@"%@",dictionary);
//        NSLog(@"%@",dictionary[Y_Message]);
//        if (dictionary) {
//            int code = [dictionary[Y_Code] intValue];
//            if (1==code) {
//                [self reloadTableViewWith:propertyId];
//                _inputMoney.text = NULL_VALUE;
//            }
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@",[error localizedDescription]);
//    }];
//    NSLog(@"1:%@",part);
    [_inputMoney resignFirstResponder];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(passRegValues:)]) {
//            UtilityBills *controller = [[UtilityBills alloc] init];
//            self.delegate = controller;
            [self.delegate passRegValues:part];
        }
    });
    
}

-(void)settingData:(UtilityBills *)utilityBills{
    propertyId = utilityBills.propertyId;
    NSArray * array = [utilityBills.earnTime componentsSeparatedByString:@"-"];
    self.month.text = array[1];
    self.year.text = array[0];
    self.unpaid.text = utilityBills.payCharge;
    int pay = [utilityBills.payCharge intValue];
    if (pay!=0) {
        _angleView.image = [UIImage imageNamed:@"utility_bills_not_pay"];
    }
    if (pay==0) {
//        CGRect frame = [self frame];
//        frame.size.height = frame.size.height -40;
//        CGRect tableFrame = [_paymentRecordsTableView frame];
//        tableFrame.origin.y = tableFrame.origin.y -40;
//        CGRect extFrame = [_extensionView frame];
//        extFrame.size.height = extFrame.size.height-40;
//        self.frame = frame;
//        _paymentRecordsTableView.frame = tableFrame;
//        _extensionView.frame = extFrame;
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.frame = frame;
//            _paymentRecordsTableView.frame = tableFrame;
//            _extensionView.frame = extFrame;
//        });
//               CGPoint tempCenter = _paymentRecordsTableView.center;
//                 tempCenter.y -= 40;
//        _paymentRecordsTableView.center = tempCenter;
//        NSLog(@"%f--%f",_paymentRecordsTableView.center.x,_paymentRecordsTableView.center.y);
    }
//    _submitBillsView.hidden=pay==0?YES:NO;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.sum.text = utilityBills.earCharge;
    _extensionView.hidden = !utilityBills.open;
    if (utilityBills.isOpen) {
      
        [self reloadTableViewWith:utilityBills.propertyId];
    }
}

//设置表格的数据源
-(void)reloadTableViewWith:(NSString *)intputPropertyId{
    payArrays = [[NSMutableArray alloc] init];
    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:intputPropertyId,@"feeId",nil];
    [manager POST:API_BASE_URL_STRING(URL_RECORDSLIST) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary= responseObject;
        if (dictionary) {
            NSLog(@"_paymentRecordsTableView:%@------------------------",dictionary);
            NSLog(@"%@",dictionary[Y_Message]);
            if (dictionary[Y_Data]) {
                dictionary = dictionary[Y_Data];
                if (dictionary[@"records"]) {
                    dictionary = dictionary[@"records"];
                    for (NSDictionary *dict in dictionary) {
                        // 创建模型对象
                        PayFeeInfo *payFeeInfo = [PayFeeInfo objectWithKeyValues:dict ];
                        // 添加模型对象到数组中
                        [payArrays addObject:payFeeInfo];
                    }
                    
                    [_paymentRecordsTableView reloadData];
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return payArrays.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PayFeeInfo *payFee= payArrays[indexPath.row];
    static NSString* indentifier = @"cell";
    PayRecordsCell* cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PayRecordsCell" owner:nil options:nil] lastObject];
    }
//    cell.layer.masksToBounds = YES;
//    cell.layer.cornerRadius = 6.0;
//    cell.layer.borderWidth = 1.0;
//    cell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, cell.frame.size.height - 1, SCREEN_WIDTH, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:227.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0].CGColor;
    [cell.layer addSublayer:bottomBorder];
    
    
    cell.name.text = payFee.createBy;
    cell.money.text = payFee.paymentAmount;
    cell.time.text = [payFee.createDate substringToIndex:16];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

//自定义区头 把区头model 创建的view写这里
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
#define labWidth SCREEN_WIDTH/3
    UIView*view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    view.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:172.0/255.0 blue:44.0/255.0 alpha:1.0];
    UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, labWidth, 20)];
    lab1.font = SystemFont(14);
    lab1.text = @"姓名";
    lab1.textAlignment = NSTextAlignmentLeft;
    UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(labWidth-30, 0, labWidth, 20)];
    lab2.font = SystemFont(14);
    lab2.text = @"缴费金额";
    lab2.textAlignment = NSTextAlignmentCenter;
    UILabel *lab3= [[UILabel alloc] initWithFrame:CGRectMake(labWidth*2-20, 0, labWidth, 20)];
    lab3.font = SystemFont(14);
    lab3.text = @"时间";
    lab3.textAlignment = NSTextAlignmentCenter;
    [view addSubview:lab1];
    [view addSubview:lab2];
    [view addSubview:lab3];
    return view;
    
}
//设置区头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 25;
}


+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"status";
    UtilityBillsCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"UtilityBillsCell" owner:nil options:nil] lastObject];
    }
    return cell;
}

@end
