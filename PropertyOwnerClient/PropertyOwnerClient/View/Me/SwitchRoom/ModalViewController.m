//
//  ModalViewController.m
//  Popping
//
//  Created by André Schneider on 16.05.14.
//  Copyright (c) 2014 André Schneider. All rights reserved.
//

#import "ModalViewController.h"
#import "SwitchRoom.h"
#import "RoomTableViewCell.h"
#import "MeViewController.h"
@interface ModalViewController()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *arrays;
- (void)addDismissButton;
- (void)dismiss:(id)sender;
@end

@implementation ModalViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self getArrays];
}
-(void)getArrays{
    _arrays = [NSMutableArray new];
  
    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
    [manager POST:API_BASE_URL_STRING(URL_FINDROOMLIST) parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary= responseObject;
          NSLog(@"%@",[[Config Instance] getRoomId]);
        NSLog(@"%@",dictionary);
        if (dictionary) {
            NSLog(@"%@",dictionary);
            if (dictionary[Y_Data]) {
                dictionary = dictionary[Y_Data];
                if (dictionary[@"records"]) {
                    dictionary = dictionary[@"records"];
                    for (NSDictionary *dict in dictionary) {
                        // 创建模型对象
                        SwitchRoom *switchRoom = [SwitchRoom objectWithKeyValues:dict ];
                        switchRoom.check = [switchRoom.roomId isEqualToString: [[Config Instance] getRoomId] ]?YES:NO;
                        // 添加模型对象到数组中
                        [_arrays addObject:switchRoom];
                    }
                    [self.tableView reloadData];
                }
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.layer.cornerRadius = 8.f;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.bounces  = NO;
    self.tableView.rowHeight = 50;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(0, 0, 0, 30);
    btn.backgroundColor = BACKGROUND_COLOR;
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    btn.tintColor = [UIColor whiteColor];
    btn.titleLabel.font = [UIFont fontWithName:@"Avenir" size:14];
    [btn setTitle:@"关闭当前" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = btn;
    //    [self addDismissButton];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _arrays.count;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//
//    return 50.0f;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SwitchRoom  *switchRoom = self.arrays[indexPath.row];
    // 1.创建cell
    RoomTableViewCell *cell = [RoomTableViewCell cellWithTableView:tableView];
    // 2.设置数据
    [cell settingData:switchRoom];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    UITableViewCell *cell =  [tableView cellForRowAtIndexPath:indexPath];
    SwitchRoom *switchRoom = [[SwitchRoom alloc] init];
    switchRoom = _arrays[indexPath.row];
    
    [SYSTEM_USERDEFAULTS setObject:switchRoom.buildingNo forKey:Y_buildingNo];
    [SYSTEM_USERDEFAULTS setObject:switchRoom.community forKey:Y_COMMUNITY];
    [SYSTEM_USERDEFAULTS setObject:switchRoom.communityId forKey:Y_COMMUNITYID];
    [SYSTEM_USERDEFAULTS setObject:switchRoom.companyId forKey:Y_COMPANYID];
    [SYSTEM_USERDEFAULTS setObject:switchRoom.ownerId forKey:Y_OWNERID];
    [SYSTEM_USERDEFAULTS setObject:switchRoom.name forKey:Y_NAME];
    [SYSTEM_USERDEFAULTS setObject:switchRoom.phone forKey:Y_PHONE];
    [SYSTEM_USERDEFAULTS setObject:switchRoom.roleType forKey:Y_ROLE_TYPE];
    [SYSTEM_USERDEFAULTS setObject:switchRoom.roomId forKey:Y_ROOMID];
    [SYSTEM_USERDEFAULTS setObject: switchRoom.roomNo forKey:Y_ROOMNO];
    [SYSTEM_USERDEFAULTS setObject:switchRoom.sex forKey:Y_SEX];
    [SYSTEM_USERDEFAULTS setObject:switchRoom.type forKey:Y_TYPE];
    [SYSTEM_USERDEFAULTS setObject:switchRoom.unitNo forKey:Y_unitNo];
    [SYSTEM_USERDEFAULTS setObject:switchRoom.photo forKey:Y_PHOTO];
    [SYSTEM_USERDEFAULTS synchronize];
    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:switchRoom.roomId,@"roomId",nil];
    
    [manager POST:API_BASE_URL_STRING(URL_switchRoom) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary= responseObject;
        NSLog(@"%@",dictionary);
        NSLog(@"%@",dictionary[Y_Message]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMe" object:self];
        [self dismiss:nil];
        
        
    });
    //更换房间更换偏好设置
    
    //    if () {
    //
    //    }
    
    //    NSArray *viewControllers=[self.navigationController viewControllers];
    //    RegisterVC *controller=[viewControllers objectAtIndex:1];
    //    controller.comModel=_communityModel;
    //    controller.roomModel = room;
    //    [self.navigationController popToViewController:controller animated:YES];
    
    //    ComplaintsDescVC *comDescVC=   [self.storyboard instantiateViewControllerWithIdentifier:@"complaintsDesc"];
    //    comDescVC.compId = complaints.compId;
    //    [self.navigationController pushViewController:comDescVC animated:YES];
    
}



#pragma mark - Private Instance methods

- (void)addDismissButton
{
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dismissButton.frame =   CGRectMake(0, 0, 0, 30);
    dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
    dismissButton.tintColor = [UIColor whiteColor];
    dismissButton.titleLabel.font = [UIFont fontWithName:@"Avenir" size:14];
    [dismissButton setTitle:@"容我想想" forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    dismissButton.layer.borderWidth = 1;
    dismissButton.layer.borderColor = [UIColor redColor].CGColor;
    //    [self.view addSubview:dismissButton];
    self.tableView.tableHeaderView = dismissButton;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:dismissButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f
                                                           constant:0.f]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:[dismissButton]-|"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(dismissButton)]];
}


- (void)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
