//
//  CCInterfacedConst.m
//  CCNetworkManager
//
//  Created by WeiPeng on 2017/7/6.
//  Copyright © 2017年 WeiPeng. All rights reserved.
//

#import "CCInterfacedConst.h"

#if DevelopSever
/** 接口前缀-开发服务器*/
NSString *const kApiPrefix = @"接口服务器的请求前缀 例: http://192.168.1.1:8080";
#elif TestSever
/** 接口前缀-测试服务器*/
NSString *const kApiPrefix = @"https://www.baidu.com";
#elif ProductSever
/** 接口前缀-生产服务器*/
NSString *const kApiPrefix = @"https://www.baidu.com";
#endif

/** 登录*/
NSString *const kLogin = @"/login";
/** 平台会员退出*/
NSString *const kExit = @"/exit";
