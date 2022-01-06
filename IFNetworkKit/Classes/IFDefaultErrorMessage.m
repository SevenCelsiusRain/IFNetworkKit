//
//  IFDefaultErrorMessage.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/6.
//

#import "IFDefaultErrorMessage.h"

@implementation IFDefaultErrorMessage

#pragma mark - Public Methods

+ (NSString *)requestParamsInvalid {
    return @"非法的请求参数";
}

+ (NSString *)timeoutMessage {
    return @"网络连接超时";
}

+ (NSString *)networkErrorMessage {
    return @"网络连接失败";
}

+ (NSString *)serverErrorMessage {
    return @"服务器开小差了";
}

@end
