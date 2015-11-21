//
//  QrcodeInfoVC.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/19.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "QrcodeInfoVC.h"

@interface QrcodeInfoVC ()
{
    int flag;//传二维码
}
- (IBAction)share:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *infoView;

@end

@implementation QrcodeInfoVC


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.name.text = self.visitorQrcode.name;
    self.community.text = self.visitorQrcode.communityName;
    self.phone.text = self.visitorQrcode.phone;
    self.qrcodeImage.image = [QRCodeGenerator qrImageForString:self.visitorQrcode.qrcodeStr imageSize:self.qrcodeImage.bounds.size.width];
    NSString * imageName = self.visitorQrcode.sex ==1?@"icon_male":@"icon_female";
    self.sexImageView.image = [UIImage imageNamed:imageName];
    
    NSString *carImageName = self.visitorQrcode.isDrive==1?@"icon_car":@"";
    self.carImageView.image = [UIImage imageNamed:carImageName];
    self.infoView.layer.masksToBounds = YES;
    self.infoView.layer.cornerRadius = 6.0;
    self.infoView.layer.borderWidth = 1.0;
    self.infoView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    flag=1;
    [self share:nil];
}


-(void)viewWillDisappear:(BOOL)animated
{
    
    if (1==flag) {
        [self addVisitorCardWithQrcode:NULL_VALUE];

    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"momomo");
}

- (IBAction)share:(id)sender {
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"分享内容"
                                       defaultContent:nil
                                                image:[ShareSDK pngImageWithImage:self.qrcodeImage.image]
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
                                if (state != SSResponseStateBegan)
                                {
                                    flag = 2;
                                    [self addVisitorCardWithQrcode:self.visitorQrcode.qrcodeStr];
                                    
                                    
                                }
                                
                            }];
}


-(void)addVisitorCardWithQrcode:(NSString *)qrcode{
    NSLog(@"name:%@", self.visitorQrcode.name);
    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:qrcode,@"qrcode",self.visitorQrcode.phone,@"phone",[NSString stringWithFormat:@"%d",self.visitorQrcode.isDrive],@"isDrive",self.visitorQrcode.name,@"name",[NSString stringWithFormat:@"%d",self.visitorQrcode.sex],@"sex",nil];
    
    [manager POST:API_BASE_URL_STRING(URL_ADDVISITORCARD) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary= responseObject;
        if (dictionary) {
            int  code = [dictionary[Y_Code] intValue];
            if (1==code) {
                NSLog(@"创建成功");
            }
        }
        NSLog(@"%@",dictionary[Y_Message]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
        [MBProgressHUD showError:@"添加失败"];
    }];
    
    
}


@end
