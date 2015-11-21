//
//  UtilityBillsVC.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/27.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "UtilityBillsVC.h"
#import "PropertyFeeDao.h"
#import "UtilityBills.h"
#import "UtilityBillsCell.h"
#import "PropertyFeeInfo.h"
@interface UtilityBillsVC ()<UITableViewDataSource,UITableViewDelegate,PassRegValueDelegate>
{
    NSInteger pageNo;
    NSInteger pageSize;
    NSMutableArray *moreArrays;
    PropertyFeeInfo *info;
    NSMutableArray *payArrays;
    NSIndexPath *chooseIndex;
}
@property (nonatomic, strong) NSMutableArray *arrays;
@end

@implementation UtilityBillsVC
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.view.backgroundColor = BACKGROUND_COLOR;
    [self getProperty];
        pageNo = 0;
    [self getArrays];

}
-(void)getProperty{
    info =[[PropertyFeeInfo alloc] init];
    self.earnFee.text = NULL_VALUE;
    [[PropertyFeeDao sharedManager] getPropertyFeeWithCompletionHandler:^(NSDictionary *dictionary, NSError *error) {
        if (dictionary) {
            dictionary = dictionary[Y_Data];
            NSLog(@"%@",dictionary);
            info = [PropertyFeeInfo objectWithKeyValues:dictionary];
            self.earnFee.text = dictionary[@"earnFee"]?dictionary[@"earnFee"]:@"0.00";
            self.payFee.text = dictionary[@"payFee"]?dictionary[@"payFee"]:@"0.00";
        }
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setHeadPhoto];
    pageSize = 5;
    moreArrays = [[NSMutableArray alloc] init];
    [self addFooter];
    self.UtilityBillsTableView.delegate =self;
    self.UtilityBillsTableView.dataSource =self;
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [ self.UtilityBillsTableView setTableFooterView:view];
    [ self.UtilityBillsTableView setTableHeaderView:view];
    view = nil;
}
-(void)getArrays{
    _arrays = [[NSMutableArray alloc] init];
    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSString stringWithFormat:@"%ld", (long)pageNo] forKey:@"pageNo"];
    [parameters setValue:[NSString stringWithFormat:@"%ld", (long)pageSize] forKey:@"pageSize"];
    [parameters setValue:@"1" forKey:@"flag"];
    [manager POST:API_BASE_URL_STRING(URL_CHARGESFEELIST) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary= responseObject;
        if (dictionary) {
            NSLog(@"%@",dictionary);
            if (dictionary[Y_Data]) {
                dictionary = dictionary[Y_Data];
                if (dictionary[@"records"]) {
                    dictionary = dictionary[@"records"];
                    for (NSDictionary *dict in dictionary) {
                        // 创建模型对象
                        UtilityBills *utilityBills = [UtilityBills objectWithKeyValues:dict ];
                        utilityBills.open = NO;
                        // 添加模型对象到数组中
                        NSArray *arrBills = [[NSArray alloc] initWithObjects:utilityBills, nil];
                        [_arrays addObject:arrBills];
                    }
                    [self.UtilityBillsTableView reloadData];
                    pageNo++;
                }
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error:%@",[error localizedDescription]);
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.arrays.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_arrays[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    //    UtilityBills *utilityBills = self.arrays[indexPath.row];
    UtilityBills * utilityBills = [[_arrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    // 1.创建cell
    UtilityBillsCell *cell = [UtilityBillsCell cellWithTableView:tableView];
    // 2.设置数据
    cell.delegate = self;
    [cell settingData:utilityBills];
    return cell;
}

-(void)passRegValues:(NSMutableDictionary *)dict{

    
        AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
        [manager POST:API_BASE_URL_STRING(URL_ADDPROPERTYFEE) parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary= responseObject;
            NSLog(@"%@",dictionary);
            NSLog(@"%@",dictionary[Y_Message]);
     
            if (dictionary) {
                if ([dictionary[Y_Code] intValue]==Y_Code_Success) {
                    pageNo=0;
                    [self getArrays];
                    [self getProperty];
                }
                else {
                    [self.view makeToast:dictionary[Y_Message] duration:1.5f position:@"center"];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",[error localizedDescription]);
        }];
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (chooseIndex&&chooseIndex!=indexPath) {
//        UtilityBills *ubs =  [[_arrays objectAtIndex:chooseIndex.section] objectAtIndex:chooseIndex.row];
//        ubs.open =NO;
//    }
//    UITableViewCell *cell =  [tableView cellForRowAtIndexPath:indexPath];
//    //    UtilityBills *utilityBills=self.arrays[indexPath.row];
//    UtilityBills * utilityBills = [[_arrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    utilityBills.open = !utilityBills.isOpen;
//    chooseIndex = indexPath;

    //    int pay = [utilityBills.payCharge intValue];
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//       [tableView reloadData];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UtilityBills * utilityBills =[[_arrays objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    if (!utilityBills.isOpen)
    {
        return   60;
    }else
    {
        return  200;
    }
}




- (void)keyboardWillChangeFrame:(NSNotification *)note
{
    // 设置窗口的颜色
    self.view.window.backgroundColor = self.UtilityBillsTableView.backgroundColor;
    
    // 0.取出键盘动画的时间
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 1.取得键盘最后的frame
    CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 2.计算控制器的view需要平移的距离
    CGFloat transformY = (keyboardFrame.origin.y -  self.view.bounds.size.height)/2;
    
    // 3.执行动画
    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, transformY);
    }];
}

#pragma mark - LoadMoreData
- (void)addFooter
{
    __unsafe_unretained typeof(self) vc = self;
    // 添加上拉刷新尾部控件
    [self.UtilityBillsTableView addFooterWithCallback:^{
        // 进入刷新状态就会回调这个Block
        [vc loadMoreData];
    }];
}

- (void)loadMoreData
{
    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSString stringWithFormat:@"%ld", (long)pageNo] forKey:@"pageNo"];
    [parameters setValue:[NSString stringWithFormat:@"%ld", (long)pageSize] forKey:@"pageSize"];
    [parameters setValue:@"1" forKey:@"flag"];
    [manager POST:API_BASE_URL_STRING(URL_CHARGESFEELIST) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary= responseObject;
        if (dictionary) {
            if (dictionary[Y_Data]) {
                dictionary = dictionary[Y_Data];
                if (dictionary[@"records"]) {
                    dictionary = dictionary[@"records"];
                    for (NSDictionary *dict in dictionary) {
                        // 创建模型对象
                        UtilityBills *utilityBills = [UtilityBills objectWithKeyValues:dict ];
                        // 添加模型对象到数组中
                        [moreArrays addObject:utilityBills];
                    }
                    [self resetActivityArrayDataResource:moreArrays];
                    pageNo++;
                }
                else{
                    [self.view.superview makeToast:Not_History_Data duration:1.0f position:@"bottom"];
                    [self.UtilityBillsTableView footerEndRefreshing];
                    return;
                }
            }
            else{
                [self.view.superview makeToast:Not_History_Data duration:1.0f position:@"bottom"];
                [self.UtilityBillsTableView footerEndRefreshing];
                return;
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
    
}

- (void)resetActivityArrayDataResource:(NSArray *)moreArray
{
    [self.UtilityBillsTableView beginUpdates];
    NSMutableArray *dataCells = [NSMutableArray array];
    NSInteger count = _arrays.count;
    for (UtilityBills *object in moreArray) {
        [dataCells addObject:[NSIndexPath indexPathForRow:count++ inSection:0]];
        [_arrays addObject:object];
    }
    [self.UtilityBillsTableView insertRowsAtIndexPaths:dataCells withRowAnimation:UITableViewRowAnimationFade];
    [self.UtilityBillsTableView endUpdates];
    [self.UtilityBillsTableView footerEndRefreshing];
}




-(void)setHeadPhoto{
    NSString *photoId = [[Config Instance] getPhoto];
    self.headImageView.image = [UIImage imageNamed:@"user_icon._white"];
    if (0==photoId.length)return;
    NSString *urlStr  = [NSString stringWithFormat:@"%@%@",URL_QINIU,photoId];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [self.headImageView.layer setCornerRadius:CGRectGetHeight([self.headImageView bounds]) / 2];
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.borderWidth = 3;
    self.headImageView.layer.borderColor = [[UIColor redColor] CGColor];

    [self.headImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"user_icon_white"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.headImageView.layer.contents = (id)[self.headImageView.image CGImage];
    }];
}



@end
