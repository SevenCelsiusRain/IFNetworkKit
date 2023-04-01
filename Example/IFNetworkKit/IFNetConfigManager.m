//
//  IFNetConfigManager.m
//  IFNetworkKit_Example
//
//  Created by MrGLZh on 2022/3/10.
//  Copyright © 2022 张高磊. All rights reserved.
//

#import <IFNetworkKit.h>
#import "IFNetConfigManager.h"
#import "IFDemoFilter.h"

@implementation IFNetConfigManager

#pragma mark - Private Methods

+ (NSDictionary<NSString *,id> *)requestHeaders {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *defaultRequestHeaders = nil;
    
    // header 配置
    dispatch_once(&onceToken, ^{
        CGSize screenSize       = [UIScreen mainScreen].bounds.size;
        NSString *screenSizeStr = [NSString stringWithFormat:@"%.0f*%.0f", screenSize.width, screenSize.height];
        defaultRequestHeaders = @{@"Content-Type":@"application/json"}.mutableCopy;
        
//        defaultRequestHeaders = @{
//                                  @"lf_appid"     : [[NSBundle mainBundle] bundleIdentifier],
//                                  @"lf_appVerion" : [UIApplication lf_appVersion],
//                                  @"lf_platform"  : @"ios",
//                                  @"lf_device"    : [UIDevice currentDevice].model,
//                                  @"lf_osVersion" : [UIDevice currentDevice].systemVersion,
//                                  @"lf_screen"    : screenSizeStr,
//                                  @"lf_deviceid"  : [UIDevice lf_globalUDID],
//                                  @"lf_timestamp" : [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]],
//                                  @"Useragent " : [self configUseragent],
//
//                                  }.mutableCopy;
    });
    //header里传的token
    defaultRequestHeaders[@"Authorization"] = [NSString stringWithFormat:@"token"];
    return defaultRequestHeaders;
}

//+ (NSString *)configUseragent {
//  return  [NSString stringWithFormat:@"LF/%@/%@/ios %@/%@/%@",
//           [UIApplication lf_appVersion],
//           [UIDevice currentDevice].model,
//           [UIDevice currentDevice].systemVersion,
//           [[NSBundle mainBundle] bundleIdentifier],@"ios"];
//}
//
#pragma mark - Public Methods
    
+ (void)configNetworkConfig {
    [IFNetworkConfigManager updateNetworkConfig:^(IFNetworkConfig *config) {
        config.baseURL = ^NSString *{
            return @"https://www.motocircle.cn/api";
        };
        config.codeKey = @"code";
        config.messageKey = @"message";
        config.commonHeaders = ^NSDictionary<NSString *,NSString *> *{
            return [IFNetConfigManager requestHeaders];
        };
        
        config.responseValidator = ^BOOL(IFBaseRequest *request) {
            IFResponseModel *responseModel = request.responseObject;
            BOOL result = YES;
            if ([responseModel isKindOfClass:[IFResponseModel class]]) {
                result = (responseModel.apiCode == 2000);
            }
            return result;
        };
        config.responseFilters = @[[[IFDemoFilter alloc] init]];
        
    } forCategory:kRequestCategoryNormal];
    
    [IFNetworkConfigManager updateNetworkConfig:^(IFNetworkConfig *config) {
        config.baseURL = ^NSString *{
            return @"https://www.motocircle.cn/api";
        };
        config.codeKey = @"code";
        config.messageKey = @"message";
        config.commonHeaders = ^NSDictionary<NSString *,NSString *> *{
            return [IFNetConfigManager requestHeaders];
        };
        
        // 响应校验 result 为 NO 会走 请求失败回调
        config.responseValidator = ^BOOL(IFBaseRequest *request) {
            IFResponseModel *responseModel = request.responseObject;
            BOOL result = YES;
            if ([responseModel isKindOfClass:[IFResponseModel class]]) {
                result = (responseModel.apiCode == 2000);
            }
            return result;
        };
        config.responseFilters = @[[[IFDemoFilter alloc] init]];
//        config.responseFilters = @[[[LKLogOutFilter alloc] init]];
        
    } forCategory:kRequestCategoryUserCenter];
}



#pragma mark - Getters and Setters

@end
