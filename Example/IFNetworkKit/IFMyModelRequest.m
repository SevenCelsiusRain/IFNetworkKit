//
//  IFMyModelRequest.m
//  IFNetworkKit_Example
//
//  Created by MrGLZh on 2022/4/22.
//  Copyright © 2022 张高磊. All rights reserved.
//

#import "IFMyModelRequest.h"

@implementation IFMyModelRequest

/**
 是否使用 mock 数据
 */
//- (BOOL)useMockData {
//    return YES;
//}

/**
 mock 数据
 */
//- (id)mockRequestWithError:(IFErrorResponseModel * _Nullable __autoreleasing *)errorModel {
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"IFDemo" ofType:@".json"];
//    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
//    NSDictionary *tempDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//    
//    return tempDict;
//}


/**
 支持全链接：
 eg:http://yapi.ifyou.cn/mock/84/tab/haveVideos (不会进行baseURL 拼接)
 非全链接：
 eg:/tab/haveVideos  (自动拼加 baseURL)
 */
- (NSString *)requestURL {
//    return @"https://www.motocircle.cn/api/brand/index";
    return @"/brand/index";
}

/**
 若设置 requestURL 拼接的 baseURL 则为当前返回，
 无返回，则拼接相应 requestCategory 设置的 baseURL
 */
//- (NSString *)baseURL {
//    return @"https://www.motocircle.cn/api";
//}


- (IFHTTPRequestMethod)httpMethod {
    return IFHTTPRequestMethodGET;
}

- (NSString *)responseModelClass {
    return @"IFDemoModel";
}

- (NSString *)requestCategory {
    return kRequestCategoryUserCenter;
}

@end
