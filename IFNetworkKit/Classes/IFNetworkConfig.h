//
//  IFNetworkConfig.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import <Foundation/Foundation.h>
#import "IFBaseRequest.h"
#import "IFRequestFilter.h"
#import "IFRequestSignature.h"
#import "IFErrorMessageProtocol.h"

typedef NSDictionary<NSString *, NSString *>* _Nullable (^IFNetworkConfigCommonBlock)(void);
typedef NSString* _Nonnull (^IFENetworkStringConfig)(void);

@class AFSecurityPolicy;
@interface IFNetworkConfig : NSObject

/**
 动态获取BaseURL配置。
 */
@property (nonatomic, copy, nullable) IFENetworkStringConfig baseURL;

/**
 动态获取UserAgent。
 */
@property (nonatomic, copy, nullable) IFENetworkStringConfig userAgent;

/**
 公共请求头。
 */
@property (nonatomic, copy, nullable) IFNetworkConfigCommonBlock commonHeaders;

/**
 公共参数集。
 */
@property (nonatomic, copy, nullable) IFNetworkConfigCommonBlock commonParams;

/**
 参考IFBaseRequest中的responseFilters。
 */
@property (nonatomic, strong, nullable) NSArray<id<IFRequestFilter>> *responseFilters;

/**
 参考IFBaseRequest中的judgementAfterResponseFilter。
 */
@property (nonatomic, copy, nullable) IFCallbackExecutionJudgement judgementAfterResponseFilter;

/**
 网络请求签名算法。
 */
@property (nonatomic, strong, nullable) id<IFRequestSignMethod> requestSignMethod;

/**
 响应体序列化实现。
 */
@property (nonatomic, strong, nullable) id<IFResponseSerialization> responseSerialization;

/**
 对于正常成功过返回响应数据的请求。未校验通过的会走请求失败的回调。
 */
@property (nonatomic, copy, nullable) IFResponseValidator responseValidator;

/**
 DEBUG模式下默认为YES，其他情况默认为NO。
 */
@property (nonatomic, assign) BOOL debugEnabled;

/**
 默认为60秒。
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@property (nonatomic, strong, nullable) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic, strong, nullable) AFSecurityPolicy *securityPolicy;

//// ----------------序列化数据段配置------------------- /////
//// 该数据段配置只有在实现了responseSerialization时，才会使用。

/**
 API状态码对应的字段Key，默认值为code。
 */
@property (nonatomic, strong, nullable) NSString *codeKey;

/**
 API信息对应的字段Key，默认值为message。
 */
@property (nonatomic, strong, nullable) NSString *messageKey;

/**
 API路由对应的字段Key，默认值为schema。
 */
@property (nonatomic, strong, nullable) NSString *schemaKey;

/**
 API数据段对应的字段Key，默认值为data。
 */
@property (nonatomic, strong, nullable) NSString *dataKey;

/**
 错误信息配置类
 */
@property (nonatomic, strong, nullable) Class<IFErrorMessageProtocol> errorMessageClass;

+ (instancetype _Nonnull)networkConfig;

@end
