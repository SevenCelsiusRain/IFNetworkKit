//
//  IFNetworkConfigManager.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/6.
//

#import <Foundation/Foundation.h>

@class IFNetworkConfig, IFBaseRequest;

typedef void (^IFNetworkConfigBlock)(IFNetworkConfig *config);

@interface IFNetworkConfigManager : NSObject

/**
 获取request对应的网络配置项。

 @param category 网络请求所属的分类。
 @return 请求对应的配置项。
 */
+ (IFNetworkConfig *)configForCategory:(NSString *)category;

/**
 针对不同的分类的请求进行单独的网络配置。

 @param configBlock 网络配置回调，在该Block种进行配置项的定制。
 @param category 请求分类，用来区分不同的网络配置项。
 */
+ (void)updateNetworkConfig:(IFNetworkConfigBlock)configBlock forCategory:(NSString *)category;

/**
 当前网络框架的SDK版本号
 */
+ (NSString *)currentSDKVersion;

@end
