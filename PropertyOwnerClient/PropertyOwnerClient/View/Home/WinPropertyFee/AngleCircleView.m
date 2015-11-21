//
//  AngleCircleView.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/6/22.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "AngleCircleView.h"

@implementation AngleCircleView

/**
 *  在view第一次显示到屏幕上的时候会调用一次
 */
- (void)drawRect:(CGRect)rect
{
    // 1.获得上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 2.画1/4圆
    CGContextMoveToPoint(ctx, advWidth/3, 0);
    CGContextAddLineToPoint(ctx, advWidth/3, advWidth/3);
    CGContextAddArc(ctx, advWidth/3, 0, advWidth/3, M_PI_2, M_PI, 0);
    CGContextClosePath(ctx);
    
    [BACKGROUND_COLOR set];
    
    // 3.显示所绘制的东西
    CGContextFillPath(ctx);
}

@end
