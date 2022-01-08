//
//  IFCommonRequestManager.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/6.
//

#import <Foundation/Foundation.h>
#import "IFNetworkKit.h"

@interface IFCommonRequestManager : NSObject

/**
 网络请求

 @param method 请求方法（IFHTTPRequestMethodGET/IFHTTPRequestMethodPOST）
 @param url 请求地址
 @param parameters 请求参数
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
+ (void)requestWithMethod:(IFHTTPRequestMethod)method
                      url:(NSString * _Nonnull)url
               parameters:(NSDictionary<NSString *, id> * _Nullable)parameters
             SuccessBlock:(IFRequestSuccessBlock _Nullable)successBlock
             failureBlock:(IFRequestFailBlock _Nullable)failureBlock;

/**
 网络请求
 可配置requestHeader、requestCategory等项

 @param method 请求方法（IFHTTPRequestMethodGET/IFHTTPRequestMethodPOST）
 @param url 请求地址
 @param parameters 请求参数
 @param headers 设置Content-Type，会自动为用户识别requestSerializerType
 @param category 对当前的网络请求进行分类，通过该分类可以获取不同的网络配置项。
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
+ (void)requestWithMethod:(IFHTTPRequestMethod)method
                      url:(NSString * _Nonnull)url
               parameters:(NSDictionary<NSString *, id> * _Nullable)parameters
                  headers:(NSDictionary<NSString *, id> * _Nullable)headers
                 category:(NSString * _Nullable)category
             SuccessBlock:(IFRequestSuccessBlock _Nullable)successBlock
             failureBlock:(IFRequestFailBlock _Nullable)failureBlock;


/**
 网络请求(可实现请求响应体自动模型转换)
 
 @param method 请求方法（IFHTTPRequestMethodGET/IFHTTPRequestMethodPOST）
 @param url 请求地址
 @param parameters 请求参数
 @param headers 设置Content-Type，会自动为用户识别requestSerializerType
 @param category 对当前的网络请求进行分类，通过该分类可以获取不同的网络配置项。
 @param responseModelClass 请求响应体实现自动模型转换的模型类名（此项有值时，将使用IFModelRequest实现请求结果自动模型转换）
 @param keyClassMapper JSON对象转换成特定对象的配置项。key:待转换JSON对象字典中的key value:将转换的对象类型名称
 @param keyPropertyMapper JSON对象转换成特定对象的配置项，自定义字典中的key对应的属性名。 key:待转换JSON对象字典中key value:将转换的属性名称
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */

+ (void)requestWithMethod:(IFHTTPRequestMethod)method
                      url:(NSString * _Nonnull)url
               parameters:(NSDictionary<NSString *, id> * _Nullable)parameters
                  headers:(NSDictionary<NSString *, id> * _Nullable)headers
                 category:(NSString * _Nullable)category
       responseModelClass:(NSString * _Nullable)responseModelClass
           keyClassMapper:(NSDictionary<NSString *, NSString *> * _Nullable)keyClassMapper
        keyPropertyMapper:(NSDictionary<NSString *, NSString *> * _Nullable)keyPropertyMapper
             SuccessBlock:(IFRequestSuccessBlock _Nullable)successBlock
             failureBlock:(IFRequestFailBlock _Nullable)failureBlock;

@end

