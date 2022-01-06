//
//  IFBaseRequest.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import <Foundation/Foundation.h>
#import "IFRequestFilter.h"
#import "IFRequestSignMethod.h"
#import "IFErrorMessageProtocol.h"

#ifndef IFBaseRequest_h
#define IFBaseRequest_h

/// HTTP Request method
typedef NS_ENUM(NSUInteger, IFHTTPRequestMethod) {
    IFHTTPRequestMethodGET = 0,
    IFHTTPRequestMethodPOST,
    IFHTTPRequestMethodHEAD,
    IFHTTPRequestMethodPUT,
    IFHTTPRequestMethodDELETE,
    IFHTTPRequestMethodPATCH,
};

/// Request serializer type
typedef NS_ENUM(NSUInteger, IFRequestSerializerType) {
    IFRequestSerializerTypeHTTP = 0,
    IFRequestSerializerTypeJSON
};

/**
 网络请求响应内容序列化类型
 1. 用来决定使用什么方式进行序列化
 2. 并且决定最终产生的responseSerializedObject属性类型
 - IFResponseSerializerTypeHTTP: NSData type
 - IFResponseSerializerTypeJSON: JSON object type
 */
typedef NS_ENUM(NSUInteger, IFResponseSerializerType) {
    IFResponseSerializerTypeHTTP = 0,
    IFResponseSerializerTypeJSON,
};

typedef NS_ENUM(NSInteger, IFRequestPriority) {
    IFRequestPriorityDefault = 0,
    IFRequestPriorityLow,
    IFRequestPriorityHigh
};

@class IFBaseRequest, IFErrorResponseModel;
@protocol AFMultipartFormData, IFRequestFilter, IFRequestSignMethod;

typedef void(^IFRequestSuccessBlock)(IFBaseRequest * _Nonnull request, id _Nullable responseObject);
typedef void(^IFRequestFailBlock)(IFBaseRequest * _Nonnull request, IFErrorResponseModel * _Nonnull errorModel);
typedef void(^IFRequestProgressBlock)(IFBaseRequest * _Nonnull request, NSProgress * _Nonnull progress);
typedef void(^IFMultiformDataConstruct)(id<AFMultipartFormData> _Nonnull multiFormData);
typedef BOOL(^IFResponseValidator)(IFBaseRequest * _Nonnull request);
typedef BOOL(^IFCallbackExecutionJudgement)(IFBaseRequest * _Nonnull request);

/**
 IFRequestDelegate: 网络请求相关的回调
 所有的方法都是在主线程中进行调用的。
 */
@protocol IFRequestDelegate <NSObject>

@optional

/**
 通知delegate网络请求已经成功。
 
 @param request 相关联的请求对象
 */
- (void)if_requestFinished:(__kindof IFBaseRequest *_Nonnull)request;

/**
 通知delegate网络请求已经失败。
 
 @param request 相关联的请求对象
 */
- (void)if_requestFailed:(__kindof IFBaseRequest *_Nonnull)request;

@end

/**
 IFRequestAccessory: 用户用来跟踪网络请求的状态。可以在这些方法中进行一些额外的配置。
 例如：一些HUD提示的展示和隐藏等。
 所有的方法都是在主线程中进行调用的。
 */
@protocol IFRequestAccessory <NSObject>

@optional

/**
 通知accessory网络请求即将开始。
 
 @param request 相关联的请求对象
 */
- (void)if_requestWillStart:(__kindof IFBaseRequest *_Nonnull)request;

/**
 通知accessory网络请求即将结束。
 
 @param request 相关联的请求对象
 */
- (void)if_requestWillStop:(__kindof IFBaseRequest *_Nonnull)request;

/**
 通知accessory网络请求已经结束。
 
 @param request 相关联的请求对象
 */
- (void)if_requestDidStop:(__kindof IFBaseRequest *_Nonnull)request;

@end

/**
 模拟网络请求所需实现的协议。
 */
@protocol IFRequestMock <NSObject>

@optional

/**
 @return 是否需要mock请求
 */
- (BOOL)useMockData;

/**
 仅当useMockData为YES的时候才进行调用。
 返回的数据对象将直接通过responseObject属性返回。

 @param errorModel 用于存放模拟的错误信息
 @return 返回模拟的数据对象
 */
- (id _Nullable)mockRequestWithError:(IFErrorResponseModel * _Nullable * _Nullable)errorModel;

/**
 @return 模拟网络请求的时间间隔
 */
- (NSTimeInterval)mockRequestLoadingTime;

@end

/**
 响应体序列化后，在经过responseValidator验证后，实际使用的数据。
 */
@protocol IFResponseValidData <NSObject>
@required
- (id _Nullable)validData;

@end

/**
 响应体进行序列化需要遵循的协议。
 */
@protocol IFResponseSerialization <NSObject>

- (id<IFResponseValidData> _Nonnull)serialize:(__kindof IFBaseRequest *_Nonnull)request
                                        error:(NSError * _Nullable * _Nullable)error;

@end

@interface IFBaseRequest : NSObject <IFRequestMock>


#pragma mark - Request Configuration

/**
 网络请求的方法, 默认为IFHTTPRequestMethodGET
 */
@property (nonatomic, assign, readonly) IFHTTPRequestMethod httpMethod;

/**
 网络请求的URL。
 1. 如果requestURL可以生成一个NSURL则使用requestURL作为请求地址。
 2. 如果baseURL存在，则和baseURL共同拼接成URL作为请求地址。
 */
@property (nonatomic, strong, readonly) NSString * _Nonnull requestURL;

/**
 请求的BaseURL。
 如果设置了该值，requestURL可以忽略掉baseURL部分直接写API路径。
 可以在API接口实现类中自定义接口的BaseURL
 */
@property (nonatomic, strong, nullable) NSString *baseURL;

/**
 API的版本号设置，该值可以为空。默认拼接规则为 baseURL+apiVersion+requestURL
 */
@property (nonatomic, strong, readonly, nullable) NSString *apiVersion;

/**
 网络请求的超时时间单位秒。默认为0。
 超时时间读取规则：
 1. 如果IFBaseRequest的timeoutInterval值大于0，则使用该值。
 2. 如果IFNetworkConfig的timeoutInterval值大于0，则使用该值。
 3. 否则默认为60.
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 设置网络请求的UserAgent。
 UserAgent的使用顺序：
 1. IFBaseRequest的requestHeaders属性中的User-Agent值。
 2. IFNetworkConfig的commondHeaders属性中返回的User-Agent值。
 3. IFBaseRequest中的userAgent。
 4. IFNetworkConfig中的userAgent。
 */
@property (nonatomic, strong, nullable) NSString *userAgent;

/**
 网络请求序列化类型，默认为IFRequestSerializerTypeHTTP
 */
@property (nonatomic, assign, readonly) IFRequestSerializerType requestSerializerType;

/**
 网络响应数据序列化类型，默认为IFResponseSerializerTypeJSON
 */
@property (nonatomic, assign, readonly) IFResponseSerializerType responseSerializerType;

/**
 网络请求参数键值对。
 由子类定义实现，如果出现和公共参数中一样的key，则覆盖公共参数中的值。
 */
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *requestParams;

/**
 网络请求Header的键值对。
 由子类定义实现，如果出现和公共Headers中一样的key，则覆盖公共参数中的值。
 设置Content-Type，会自动为用户识别requestSerializerType
 */
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *requestHeaders;

/**
 是否允许蜂窝网络访问。默认为YES。
 */
@property (nonatomic, assign, readonly) BOOL allowsCellularAccess;

/**
 设置网络请求的优先级，默认为IFRequestPriorityDefault。
 */
@property (nonatomic, assign) IFRequestPriority requestPriority;

/**
 对当前的网络请求进行分类，通过该分类可以获取不同的网络配置项。
 */
@property (nonatomic, strong, nullable) NSString *requestCategory;

/**
 用于标记请求为资源下载请求，默认值为nil。
 */
@property (nonatomic, strong, nullable) NSString *resumableDownloadPath;

/**
 网络请求签名算法。
 */
@property (nonatomic, strong, readonly, nullable) id<IFRequestSignMethod> signMethod;

/**
 响应体序列化实现。
 */
@property (nonatomic, strong, readonly, nullable) id<IFResponseSerialization> responseSerialization;

/**
 对于正常成功过返回响应数据的请求。未校验通过的会走请求失败的回调。
 */
@property (nonatomic, copy, nullable) IFResponseValidator responseValidator;


#pragma mark - Callback & Delegate

/**
 网络请求回调
 */
@property (nonatomic, weak, nullable) id<IFRequestDelegate> delegate;

/**
 文件上传的回调，可以将文件数据添加到form数据中。
 理想状态是requestParams里面只是放普通类型的参数，这个回调用设置文件类型的参数。
 转换为HTTP请求类型为Multiform-data类型。
 */
@property (nonatomic, strong, readonly, nullable) IFMultiformDataConstruct multiformConstructor;

/**
 网络请求处理成功的回调
 */
@property (nonatomic, copy, nullable) IFRequestSuccessBlock successBlock;

/**
 网络请求处理失败的回调
 NSError的code不同的值代表不同的错误。给底层网络请求错误预留特定的错误码。
 对于API返回的code值，按照请求返回，message信息在message
 */
@property (nonatomic, copy, nullable) IFRequestFailBlock failureBlock;

/**
 网络请求进度的回调
 */
@property (nonatomic, copy, nullable) IFRequestProgressBlock progressBlock;


#pragma mark - Request Information
@property (nonatomic, strong, readonly, nullable) NSURLSessionTask *sessionTask;
@property (nonatomic, strong, readonly, nullable) NSURLRequest *originRequest;
@property (nonatomic, strong, readonly, nullable) NSURLRequest *currentRequest;

@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;
@property (nonatomic, readonly, getter=isExecuting) BOOL executing;


#pragma mark - Response Information
@property (nonatomic, assign, readonly) NSInteger statusCode;
@property (nonatomic, strong, readonly, nullable) NSData *responseData;
@property (nonatomic, strong, readonly, nullable) NSString *responseString;
@property (nonatomic, strong, readonly, nullable) id responseJSONObject;
@property (nonatomic, strong, readonly, nullable) id responseObject;
@property (nonatomic, strong, readonly, nullable) NSHTTPURLResponse *response;
@property (nonatomic, strong, readonly, nullable) NSDictionary *responseHeaders;

/**
 网络请求过程中出现失败的情况，返回的错误信息。
 */
@property (nonatomic, strong, nullable) IFErrorResponseModel *errorModel;

/**
 错误信息配置类
 */
@property (nonatomic, strong, readonly, nullable) Class<IFErrorMessageProtocol> errorMessageClass;

#pragma mark - Filters & Accessories

/**
 对于网络请求的响应内容进行过滤器配置。过滤器生效规则如下：
 1. 优先使用IFBaseRequest类中的responseFilter过滤器。
 2. 遍历IFBaseRequest的category对应IFNetworkConfig中的responseFilters，返回YES的则中断遍历。
 3. 如果遇到合适的过滤器，则不执行IFBaseRequest的delegate和block回调。
 4. 否则继续执行IFBaseRequest的delegate和block回调。
 */
@property (nonatomic, strong, nullable) id<IFRequestFilter> responseFilter;

/**
 在网络请求的响应内容被responseFilter过滤后，调用该Block来判断是否要继续执行网络请求的几个delegate方法和Block回调。
 默认情况下是不再执行网络请求的回调。
 */
@property (nonatomic, copy, nullable) IFCallbackExecutionJudgement judgementAfterResponseFilter;

/**
 网络请求的辅助操作。一般的可以用来进行一些全局动画的配置。
 */
@property (nonatomic, strong, nullable) NSMutableArray<id<IFRequestAccessory>> *requestAccessories;

/**
 @return Request是否在默认分类中。
 */
- (BOOL)inDefaultCategory;

/**
 本地验证请求参数的合法性。
 
 @param errorMessage 未通过本地验证的提示错误信息。
 @return 是否通过本地验证。默认返回YES。
 */
- (BOOL)validateRequestParams:(NSString * _Nullable * _Nullable)errorMessage;

/**
 清空block设置，防止循环引用。
 */
- (void)clearCompletionBlock;

/**
 将当前请求加入到请求队列当中，并开始请求。
 */
- (void)start;

/**
 从请求队列中删除当前请求，并取消请求。
 */
- (void)stop;

/**
 使用callback回调的快捷开始请求的方法。
 
 @param successBlock 成功的回调。
 @param failureBlock 失败的回调。
 */
- (void)startWithSuccessBlock:(IFRequestSuccessBlock _Nullable)successBlock
                 failureBlock:(IFRequestFailBlock _Nullable)failureBlock;

/**
 @return 判断网络请求的响应码是否合法。
 */
- (BOOL)isResponseStatusCodeValid;


@end

#endif
