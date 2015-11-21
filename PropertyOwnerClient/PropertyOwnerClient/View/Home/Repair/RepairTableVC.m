//
//  RepairTableVC.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/6/11.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "RepairTableVC.h"
#import "RepairInfo.h"
#import "RepairCell.h"
#import "RepairDesc.h"
#import "UITableView+Add.h"
#import "EvaluationVC.h"
@interface RepairTableVC ()<UITableViewDelegate,UITableViewDataSource>
{
    UIScrollView *scrollView;
}
@property (nonatomic, strong) NSMutableArray *arrays;
@end

@implementation RepairTableVC
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.view.backgroundColor = BACKGROUND_COLOR;
    [self setData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 150;
    self.tableView.delegate =self;
    self.tableView.dataSource =self;
    _arrays = [[NSMutableArray alloc] init];
    
//    [self.tableView setExtraCellLineHidden];
    self.tableView.backgroundColor = ALLBACKCOLOR;
    //    self.tableView .bounces = NO;
}

-(void)setData{
    NSInteger index =  0;
    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[[Config Instance] getRoomId],@"roomOrCommunityId",[NSString stringWithFormat:@"%ld",(long)index],@"scheduleType",nil];
    [[AnimationView animationClass]createAnimation:YES toText:nil toView:self.view];
    [manager POST:API_BASE_URL_STRING(URL_FINREPAIRLISTBYROOMID) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary= responseObject;
        NSLog(@"%@",dictionary);
        [[AnimationView animationClass]hideViewToView:self.view];
        if (_arrays!=nil) {
            [_arrays removeAllObjects];
            if (dictionary) {
                
                if (dictionary[Y_Data]) {
                    dictionary = dictionary[Y_Data];
                    if (dictionary[@"records"]) {
                        
                        dictionary = dictionary[@"records"];
                        for (NSDictionary *dict in dictionary) {
                            // 创建模型对象
                            RepairInfo *repairInfo = [RepairInfo objectWithKeyValues:dict ];
                            // 添加模型对象到数组中
                            [_arrays addObject:repairInfo];
                        }
                    }
                }
            }
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
        [[AnimationView animationClass]createAnimation:NO toText:NetError toView:self.view];
    }];
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arrays.count;
}


- (BOOL)prefersStatusBarHidden
{
    return NO; //返回NO表示要显示，返回YES将hiden
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RepairInfo *repairInfo = self.arrays[indexPath.row];
    
    // 1.创建cell
    RepairCell *cell = [RepairCell cellWithTableView:tableView];
    // 2.设置数据
    [cell settingData:repairInfo];
    NSArray * picArray = [repairInfo.photo componentsSeparatedByString:@"&#"];
    
    for (int i = 0; i<picArray.count-1;i++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5 + i*50 +i *5, 0,50,50 )];
        [imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_QINIU,picArray[i]]] placeholderImage:[UIImage imageNamed:@"aio_image_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        UIButton *imageBtn = [[UIButton alloc] initWithFrame:CGRectMake(5 + i*50 +i *5, 0,50,50 )];
        [imageBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        imageBtn.titleLabel.text=picArray[i];
        [cell.picView addSubview:imageBtn];
        [cell.picView addSubview:imgView];
    }
    [cell.evaluation  addTarget:self action:@selector(evaluationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.evaluation.tag = indexPath.row;
    return cell;
}

-(void)click:(id)btn{
    UIButton *button = (UIButton *)btn;
    /**
     *  隐藏导航栏  隐藏状态栏
     */
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:1.0];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    [UIView commitAnimations];


    
    // 1.创建UIScrollView
    scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT); // frame中的size指UIScrollView的可视范围
    scrollView.backgroundColor = [UIColor blackColor];
    UIButton *imgbtn = [[UIButton alloc] init];
    //    imgbtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [imgbtn addTarget:self action:@selector(lookImage:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:imgbtn];
    [self.view addSubview:scrollView];
    
    // 2.创建UIImageView（图片）
    UIImageView *imageView = [[UIImageView alloc] init];
    [[AnimationView animationClass ]createAnimation:YES toText:nil toView:self.view];
    [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URL_QINIU,button.titleLabel.text]]
                 placeholderImage:[UIImage imageNamed:@"aio_image_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                     [[AnimationView animationClass] hideViewToView:self.view];
                 }];
    CGFloat imgW = imageView.image.size.width; // 图片的宽度
    CGFloat imgH = imageView.image.size.height; // 图片的高度
    imageView.frame = CGRectMake(0, 0, imgW, imgH);
    
    [scrollView addSubview:imageView];
    NSLog(@"%f",imageView.frame.size.height);
    imgbtn.frame = CGRectMake(0, 0, imageView.frame.size.width, SCREEN_HEIGHT);
    // 3.设置scrollView的属性
    if (imgW<SCREEN_HEIGHT&&imgH>SCREEN_HEIGHT) {
        imageView.frame = CGRectMake((SCREEN_WIDTH-imgW)/2, 0, imgW, imgH);
    }
    else if (imgH<SCREEN_HEIGHT) {
        imageView.frame = CGRectMake(0, (SCREEN_HEIGHT-imgH)/2, imgW, imgH);
    }
    else  if (imgW<SCREEN_WIDTH&&imgH<SCREEN_HEIGHT) {
        imageView.frame = CGRectMake((SCREEN_WIDTH-imgW)/2, (SCREEN_HEIGHT-imgH)/2, imgW, imgH);
    }
    
    // 设置UIScrollView的滚动范围（内容大小）
    scrollView.contentSize = imageView.image.size;
    
    // 隐藏水平滚动条
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    // 去掉弹簧效果
    scrollView.bounces = NO;
    self.tableView.bounces = NO;
}
-(void)lookImage:(UIButton *)btn{
    self.tableView .bounces = YES;

    [self.navigationController setNavigationBarHidden:NO]; 
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [scrollView removeFromSuperview];


}
-(void)evaluationBtnClick:(UIButton *)btn
{
    
    RepairInfo *repairInfo = self.arrays[btn.tag];
    EvaluationVC *evaluationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EvaluationVC"];
    evaluationVC.title = @"评价";
    evaluationVC.repairInfo = repairInfo;
    [self.navigationController pushViewController:evaluationVC animated:YES];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RepairInfo *repairInfo = _arrays[indexPath.row];
    RepairDesc *repairDesc = [self.storyboard instantiateViewControllerWithIdentifier:@"RepairDesc"];
    repairDesc.repairId=repairInfo.repairId;
    repairDesc.title=@"报修详情";
    [self.navigationController pushViewController:repairDesc animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

@end
