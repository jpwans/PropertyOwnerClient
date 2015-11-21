//
//  WinPropertyFeeVC.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/26.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "WinPropertyFeeVC.h"
#import "Advertising.h"
#import "AdvertisingVC.h"
#import "PropertyFeeDao.h"
#import "AdvTableViewCell.h"
@interface WinPropertyFeeVC ()
{
    NSInteger pageNo;
    NSInteger pageSize;
    NSMutableArray *moreArrays;
}
@property (nonatomic, strong) NSMutableArray *arrays;
@end

@implementation WinPropertyFeeVC

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.view.backgroundColor = BACKGROUND_COLOR;
    [super viewWillAppear:animated];
    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
    [manager POST:API_BASE_URL_STRING(URL_TODAYEARNFEE) parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary= responseObject;
        if (dictionary) {
            self.todayGain.text =dictionary[Y_Data][@"ownerProfit"]?dictionary[Y_Data][@"ownerProfit"]:@"0.00";
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
    [[PropertyFeeDao sharedManager] getPropertyFeeWithCompletionHandler:^(NSDictionary *dictionary, NSError *error) {
        if (dictionary) {
            dictionary = dictionary[Y_Data];
            NSLog(@"%@",dictionary);
            self.winFee.text =dictionary[@"earnFee"]?dictionary[@"earnFee"]:@"0.00";
        }
        else{
            NSLog(@"error:%@",[error localizedDescription]);
        }
    }];
    pageNo = 0;
    pageSize = 10;
    [self getArrays];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
   self.advertisingTableView.delegate=self;
    self.advertisingTableView.dataSource =self;
    self.advertisingTableView.backgroundColor = ALLBACKCOLOR;
    moreArrays = [[NSMutableArray alloc] init];
    [self addFooter];
//    self.advertisingTableView.rowHeight = 100;
}

-(void)getArrays{

    _arrays = [[NSMutableArray alloc] init];
    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSString stringWithFormat:@"%ld", (long)pageNo] forKey:@"pageNo"];
    [parameters setValue:[NSString stringWithFormat:@"%ld", (long)pageSize] forKey:@"pageSize"];
    [manager POST:API_BASE_URL_STRING(URL_FINDALLADVERTISELIST) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary= responseObject;
        NSLog(@"%@",dictionary);
        if (dictionary) {
            if (dictionary[Y_Data]) {
                dictionary = dictionary[Y_Data];
                if (dictionary[@"records"]) {
                    dictionary = dictionary[@"records"];
                    for (NSDictionary *dict in dictionary) {
                        // 创建模型对象
                        Advertising *advertising = [Advertising objectWithKeyValues:dict ];
                        // 添加模型对象到数组中
                        [_arrays addObject:advertising];
                    }
                    [self.advertisingTableView reloadData];
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
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arrays.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Advertising * advertising =_arrays[indexPath.row];
    // 1.创建cell
    AdvTableViewCell *cell =[AdvTableViewCell cellWithTableView:tableView];
       // 2.设置数据
    [cell settingData:advertising];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    float cellH = SCREEN_WIDTH * 180 /720;
    return advWidth;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Advertising *advertising=  [[Advertising alloc] init];
    advertising = self.arrays[indexPath.row];
    AdvertisingVC *advertisingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AdvertisingVC"];
    advertisingVC.advertising = advertising;
    advertisingVC.title=@"广告";
    [self.navigationController pushViewController:advertisingVC animated:YES];
}

#pragma mark - LoadMoreData
- (void)addFooter
{
    __unsafe_unretained typeof(self) vc = self;
    // 添加上拉刷新尾部控件
    [self.advertisingTableView addFooterWithCallback:^{
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
    [manager POST:API_BASE_URL_STRING(URL_FINDALLADVERTISELIST) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary= responseObject;
        if (dictionary) {
            if (dictionary[Y_Data]) {
                dictionary = dictionary[Y_Data];
                if (dictionary[@"records"]) {
                    dictionary = dictionary[@"records"];
                    for (NSDictionary *dict in dictionary) {
                        // 创建模型对象
                        Advertising *advertising = [Advertising objectWithKeyValues:dict ];
                        // 添加模型对象到数组中
                        [moreArrays addObject:advertising];
                    }
                    [self resetActivityArrayDataResource:moreArrays];
                    pageNo++;
                }
                else{
                    [self.view.superview makeToast:Not_History_Data duration:1.0f position:@"bottom"];
                    [self.advertisingTableView footerEndRefreshing];
                    return;
                }
            }
            else{
                [self.view.superview makeToast:Not_History_Data duration:1.0f position:@"bottom"];
                [self.advertisingTableView footerEndRefreshing];
                return;
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
    
}

- (void)resetActivityArrayDataResource:(NSArray *)moreArray
{
    [self.advertisingTableView beginUpdates];
    NSMutableArray *dataCells = [NSMutableArray array];
    NSInteger count = _arrays.count;
    for (Advertising *object in moreArray) {
        [dataCells addObject:[NSIndexPath indexPathForRow:count++ inSection:0]];
        [_arrays addObject:object];
    }
    [self.advertisingTableView insertRowsAtIndexPaths:dataCells withRowAnimation:UITableViewRowAnimationFade];
    [self.advertisingTableView endUpdates];
    [self.advertisingTableView footerEndRefreshing];
}



@end
