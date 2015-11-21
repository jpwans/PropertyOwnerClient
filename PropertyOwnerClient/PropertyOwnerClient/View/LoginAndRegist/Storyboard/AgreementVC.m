//
//  AgreementVC.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/6/16.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "AgreementVC.h"

@implementation AgreementVC
-(void)viewDidLoad{
    [super viewDidLoad];
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:API_BASE_URL_STRING(URL_SERVICEPROTOCOL)]];

    [_webView loadRequest:request];
}
@end
