//
//  VisitorTableVC.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/18.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "VisitorTableVC.h"
#import "VisitorCard.h"
#import "VisitorTableViewCell.h"
#import "VisitorDao.h"
@interface VisitorTableVC ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    NSIndexPath *jumpIndexPath;
    NSInteger pageNo;
    NSInteger pageSize;
    NSMutableArray *moreArrays;
    //    AnimationView *animationView;
}
@property (nonatomic, strong) NSMutableArray *arrays;
@end

@implementation VisitorTableVC
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addFooter];
    
    
    
    moreArrays = [[NSMutableArray alloc] init];
    
    //    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    //        self.edgesForExtendedLayout = UIRectEdgeNone;
    //    self.view.bounds = BOTTOM_FRAME;
    self.tableView.rowHeight = 100;
    self.tableView.backgroundColor=[UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0f];
    //    self.tableView.sectionFooterHeight=10;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.view.backgroundColor = BACKGROUND_COLOR;
    pageNo = 0;
    pageSize = 5;
    [self getArrays];
}

-(void)getArrays{
    _arrays = [NSMutableArray array];
    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheader];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSString stringWithFormat:@"%ld", (long)pageNo] forKey:@"pageNo"];
    [parameters setValue:[NSString stringWithFormat:@"%ld", (long)pageSize] forKey:@"pageSize"];
    [[AnimationView animationClass] createAnimation:YES toText:nil toView:self.view];
    [manager POST:API_BASE_URL_STRING(URL_GETVISITORLIST) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary= responseObject;
        NSLog(@"%@",dictionary);
        
        if (dictionary) {
            int code = [dictionary[Y_Code] intValue];
            if (code==Y_Code_Failure) {
                [[AnimationView animationClass] createAnimation:NO toText:nil toView:self.view];
                return ;
            }
            dictionary = dictionary[Y_Data];
            if (dictionary[@"records"]) {
                [[AnimationView animationClass] hideViewToView:self.view];
                
                dictionary = dictionary[@"records"];
                for (NSDictionary *dict in dictionary) {
                    // 创建模型对象
                    VisitorCard *visitorCard = [VisitorCard objectWithKeyValues:dict];
                    // 添加模型对象到数组中
                    [_arrays addObject:visitorCard];
                }
                [self.tableView reloadData];
                if (self.isBack) {//跳转回来直接展示发送页面
                    NSIndexPath *indexPath =[NSIndexPath indexPathForRow:0 inSection:0];
                    VisitorCard * visitor = self.arrays[indexPath.row];
                    int state = [[NSString stringWithFormat:@"%@",visitor.visitState] intValue];
                    if (3==state) {
                        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                    }
                }
                pageNo++;
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
        [[AnimationView animationClass] createAnimation:NO toText:NetError toView:self.view];
    }];
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arrays.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VisitorCard *visitorCard = self.arrays[indexPath.row];
    // 1.创建cell
    VisitorTableViewCell *cell = [VisitorTableViewCell cellWithTableView:tableView];
    // 2.设置数据
    [cell settingData:visitorCard];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- ( CGFloat )tableView:( UITableView *)tableView heightForHeaderInSection:( NSInteger )section
{
    return 8.0 ;
}
/**
 *  点击选中行
 *
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    jumpIndexPath = indexPath;
    VisitorCard * visitor = self.arrays[indexPath.row];
    int state = [[NSString stringWithFormat:@"%@",visitor.visitState] intValue];
    if (3==state) {
        NSString *qrcode =  [NSString stringWithFormat:@"name:%@&#sex:%@&#phone:%@&#isDrive:%@&#communityName:%@",visitor.name,visitor.sex,visitor.phone,visitor.isDrive,[[Config Instance] getCommunityName]];
          qrcode = [DES3Util encrypt:qrcode];
        UIImage *img=    [QRCodeGenerator qrImageForString:qrcode imageSize:500];
        [self shareWithImage:img];
    }
    else{
        UIActionSheet *sheet = [[UIActionSheet alloc]  initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"重新生成", nil];
        [sheet showInView:self.view];
        
    }
    
}



//弹出分享菜单
-(void)shareWithImage:(UIImage *)image{
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"分享内容"
                                       defaultContent:nil
                                                image:[ShareSDK jpegImageWithImage:image quality:1.0]
                                                title:nil
                                                  url:nil
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeImage];
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPhoneContainerWithViewController:self];
    
    //弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                NSLog(@"%d",state);
                                if (state == SSResponseStateSuccess)
                                {
                                    VisitorCard *visitorCard = _arrays[jumpIndexPath.row];
                                            NSString *qrcode =  [NSString stringWithFormat:@"name:%@&#sex:%@&#phone:%@&#isDrive:%@&#communityName:%@",visitorCard.name,visitorCard.sex,visitorCard.phone,visitorCard.isDrive,[[Config Instance] getCommunityName]];
                                    
                                    qrcode = [DES3Util encrypt:qrcode];
                                    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
                                    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                visitorCard.visitId,@"visitorId",
                                                                qrcode,@"qrcode",
                                                                @"0",@"flag",nil];
                                    
                                    [manager POST:API_BASE_URL_STRING(URL_UPDATEVISITOR) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        NSDictionary *dictionary= responseObject;
                                        NSLog(@"%@",dictionary[Y_Message]);
                                        if ([dictionary[Y_Code] intValue]==Y_Code_Success) {
                                            pageNo = 0;
                                            [self getArrays];
                                        }
                                        
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"%@",[error localizedDescription]);
                                    }];
                                
                                }
                            }];
    //
}
#pragma mark 当用户提交了一个编辑操作就会调用（比如点击了“删除”按钮）
// 只要实现了这个方法，就会默认添加滑动删除功能
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 如果不是删除操作，直接返回
    if (editingStyle != UITableViewCellEditingStyleDelete) return;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]  initWithTitle:@"您确定要删除吗？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil, nil];
    jumpIndexPath = indexPath;
    [sheet showInView:self.view];
    
}

#pragma mark - ActionSheet代理方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0&&actionSheet.destructiveButtonIndex==-1) {
        
        //重新生成调用添加的接口
        VisitorCard *visitorCard = _arrays[jumpIndexPath.row];
        NSString *qrcode =  [NSString stringWithFormat:@"name:%@&#sex:%@&#phone:%@&#isDrive:%@&#visitTime:%@&#communityName:%@",visitorCard.name,visitorCard.sex,visitorCard.phone,visitorCard.isDrive,[[PublicClass sharedManager] getNowTimeWithFormat:@"yyyyMMDDHHmm"],[[Config Instance] getCommunityName]];
        NSLog(@"%@",qrcode);
        qrcode = [DES3Util encrypt:qrcode];
        AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    visitorCard.phone,@"phone",
                                 visitorCard.isDrive   ,@"isDrive",
                                    visitorCard.name,@"name",
                                   visitorCard.sex,@"sex",
                                    nil];
        
        [manager POST:API_BASE_URL_STRING(URL_ADDVISITORCARD) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary= responseObject;
            if (dictionary) {
                if (Y_Code_Success== [dictionary[Y_Code] intValue]) {
                    NSLog(@"创建成功");
                    [self getArrays];
                    //                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            NSLog(@"%@",dictionary[Y_Message]);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",[error localizedDescription]);
            [MBProgressHUD showError:@"添加失败"];
        }];

//        AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
//        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:visitorCard.visitId,@"visitorId",qrcode,@"qrcode",@"1",@"flag",nil];
//        NSLog(@"%@",parameters);
//        [manager POST:API_BASE_URL_STRING(URL_UPDATEVISITOR) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSDictionary *dictionary= responseObject;
//            NSLog(@"%@",dictionary[Y_Message]);
//            
//            pageNo=0;
//            [self getArrays];
//            [self.view makeToast:dictionary[Y_Message] duration:1.5f position:@"center"];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"%@",[error localizedDescription]);
//        }];
//        
        
    }else
        if (actionSheet.destructiveButtonIndex==0&&buttonIndex==0) {
            //删除
            NSLog(@"删除");
            if (_arrays.count) {
                VisitorCard *visitorCard = _arrays[jumpIndexPath.row];
                
                AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:visitorCard.visitId,@"visitorId",nil];
                
                [manager POST:API_BASE_URL_STRING(URL_DELETEVISITOR) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSDictionary *dictionary= responseObject;
                    if (dictionary) {
                        if (dictionary[Y_Code]) {
                            int code = [dictionary[Y_Code] intValue];
                            if (1==code) {
                                [_arrays removeObjectAtIndex:jumpIndexPath.row];
                                [self.tableView deleteRowsAtIndexPaths:@[jumpIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                NSLog(@"%@",dictionary[Y_Message]);
                            }
                        }
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"%@",[error localizedDescription]);
                }];
                
                
            }
            
        }
    
    //    if (buttonIndex == 1) return;
    //    NSIndexPath  * indexPath = [self.tableView indexPathForSelectedRow];
    //  NSLog(@"%lu",(unsigned long)_arrays.count);
    //    if (_arrays.count) {
    //        [_arrays removeObjectAtIndex:indexPath.row];
    //        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    //    }
    
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
    [manager POST:API_BASE_URL_STRING(URL_GETVISITORLIST) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary= responseObject;
        if (dictionary) {
            if (dictionary[Y_Data]) {
                dictionary = dictionary[Y_Data];
                if (dictionary[@"records"]) {
                    dictionary = dictionary[@"records"];
                    for (NSDictionary *dict in dictionary) {
                        // 创建模型对象
                        VisitorCard *visitorCard = [VisitorCard objectWithKeyValues:dict ];
                        // 添加模型对象到数组中
                        [moreArrays addObject:visitorCard];
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
            else{
                [self.view.superview makeToast:Not_History_Data duration:1.0f position:@"bottom"];
                [self.tableView footerEndRefreshing];
                return;
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
    NSInteger count = _arrays.count;
    for (VisitorCard *object in moreArray) {
        [dataCells addObject:[NSIndexPath indexPathForRow:count++ inSection:0]];
        [_arrays addObject:object];
    }
    [self.tableView insertRowsAtIndexPaths:dataCells withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self.tableView footerEndRefreshing];
}



@end
