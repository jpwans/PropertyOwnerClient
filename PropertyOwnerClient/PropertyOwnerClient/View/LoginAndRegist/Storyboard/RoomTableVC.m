//
//  RoomTableVC.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/16.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "RoomTableVC.h"
#import "RegisterVC.h"
@interface RoomTableVC ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    BOOL isFiltered; // 标识是否正在搜素
    UIView *mask;
    NSInteger pageNo;
    NSInteger pageSize;
    NSMutableArray *moreArrays;
}
@end

@implementation RoomTableVC
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    pageNo = 0;
    pageSize = 15;
    [self getRoomArray];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , 44)];
    searchBar.placeholder = @"请输入房间号";
    // 添加 searchbar 到 headerview
    self.tableView.tableHeaderView = searchBar;
    searchBar.delegate = self;
    // 添加一层 mask
    mask = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height -44)];
    [self.view addSubview:mask];
    mask.backgroundColor = [UIColor blackColor];
    mask.alpha = 0;
    
    moreArrays = [[NSMutableArray alloc] init];
    [self addFooter];
}
-(void)getRoomArray{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSString stringWithFormat:@"%ld", (long)pageNo] forKey:@"pageNo"];
    [parameters setValue:[NSString stringWithFormat:@"%ld", (long)pageSize] forKey:@"pageSize"];
    [parameters setValue: _communityModel.communityId forKey:@"officeId"];
        [manager GET:API_BASE_URL_STRING(URL_GETROOM) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
             _roomArray = [NSMutableArray new];
            if (dictionary[Y_Data]) {
                dictionary =dictionary[Y_Data][@"records"];
                for (NSDictionary *dict in dictionary) {
                    // 创建模型对象
                    Room *roomEntity = [Room roomWithDict:dict];
                    // 添加模型对象到数组中
                    [_roomArray addObject:roomEntity];
                }
                [self.tableView reloadData];
                pageNo++;
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        }];

}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // 开始搜索时弹出 mask 并禁止 tableview 点击
    NSLog(@"searchBarTextDidBeginEditing");
    isFiltered = YES;
    searchBar.showsCancelButton = YES;
    mask.alpha = 0.3;
    self .tableView.allowsSelection = NO;
    self.tableView.scrollEnabled = NO;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) sb{
    // 点击 cancel 时去掉 mask ,reloadData
    sb.text = @"";
    [sb setShowsCancelButton:NO animated:YES];
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
    [sb resignFirstResponder];
    mask.alpha = 0;
    
    isFiltered = NO;
    [self.tableView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
   
    NSLog(@"%@",[searchBar.text trimString]);
    pageNo = 0;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:_communityModel.communityId,@"communityId",[searchBar.text trimString],@"roomNo",nil];
    NSLog(@"%@",API_BASE_URL_STRING(URL_GETROOMLIST));
    [manager POST:API_BASE_URL_STRING(URL_GETROOMLIST) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary= responseObject;
        NSLog(@"%@",dictionary);

        if (dictionary[Y_Data]) {
            dictionary =dictionary[Y_Data][@"records"];
//            _roomArray=nil;
                    _roomArray = [NSMutableArray array];
            for (NSDictionary *dict in dictionary) {
                // 创建模型对象
                Room *roomEntity = [Room objectWithKeyValues:dict];
                // 添加模型对象到数组中
                [_roomArray addObject:roomEntity];
            }
            [searchBar setShowsCancelButton:NO animated:YES];
            self.tableView.allowsSelection = YES;
            self.tableView.scrollEnabled = YES;
            [searchBar resignFirstResponder];
            mask.alpha = 0;
            
            isFiltered = NO;
            [self.tableView reloadData];
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
    return self.roomArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"show";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    //数据显示
    Room *room = self.roomArray[indexPath.row];
    // 设置cell的数据
    cell.textLabel.text =  [NSString stringWithFormat:@"%@/%@/%@",room.buildingNo,room.unitNo,room.roomNo];
    cell.detailTextLabel.text = room.roomId;
    cell.detailTextLabel.hidden = YES;
    // 设置cell右边指示器的类型
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSLog(@"当前选中行%ld",(long)indexPath.row);
    UITableViewCell *cell =  [tableView cellForRowAtIndexPath:indexPath];
    Room *room  = [[Room alloc] init];
    room.roomNo = cell.textLabel.text;
    room.roomId = cell.detailTextLabel.text;
    dispatch_async(dispatch_get_main_queue(), ^{

        NSArray *viewControllers=[self.navigationController viewControllers];
        RegisterVC *controller=[viewControllers objectAtIndex:1];
        controller.comModel=_communityModel;
        controller.roomModel = room;
        [self.navigationController popToViewController:controller animated:YES];

        self.delegate = controller;
    if ([self.delegate respondsToSelector:@selector(passRegValues:andRoom:)]) {
       
        [self.delegate passRegValues:_communityModel andRoom:room];
    }

    });
}

#pragma mark - LoadMoreData
- (void)addFooter
{
    __unsafe_unretained typeof(self) vc = self;
    // 添加上拉刷新尾部控件
    [self.tableView addFooterWithCallback:^{
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
    [parameters setValue: _communityModel.communityId forKey:@"officeId"];
    [manager POST:API_BASE_URL_STRING(URL_GETROOM) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary= responseObject;
        if (dictionary) {
            if (dictionary[Y_Data]) {
                dictionary = dictionary[Y_Data];
                if (dictionary[@"records"]) {
                    dictionary = dictionary[@"records"];
                    moreArrays = [NSMutableArray new];
                    for (NSDictionary *dict in dictionary) {
                        // 创建模型对象
                        Room *room = [Room objectWithKeyValues:dict];
                        // 添加模型对象到数组中
                        [moreArrays addObject:room];
                    }
                    [self resetActivityArrayDataResource:moreArrays];
                    pageNo++;
                }
                else{
                    [self.view.superview makeToast:Not_History_Data duration:1.0f position:@"bottom"];
                    [self.tableView footerEndRefreshing];
                    return;
                }
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
    
}

- (void)resetActivityArrayDataResource:(NSArray *)moreArray
{
    [self.tableView beginUpdates];
    NSMutableArray *dataCells = [NSMutableArray array];
    NSInteger count = _roomArray.count;
    for (Room *object in moreArray) {
        [dataCells addObject:[NSIndexPath indexPathForRow:count++ inSection:0]];
        [_roomArray addObject:object];
    }
    [self.tableView insertRowsAtIndexPaths:dataCells withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self.tableView footerEndRefreshing];
}



@end
