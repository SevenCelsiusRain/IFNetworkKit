//
//  IFStubRequestManager.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import "IFStubRequestManager.h"
#import "IFBaseRequest.h"
#import "IFRequestSignature.h"
#import "IFNetworkConfig.h"
#import "IFRequestCache.h"
#import "IFNetworkConfigManager.h"
#import "IFNetworkDefines.h"
#import "IFNetworkPrivateUtils.h"
#import "IFResponseModel.h"
#import "IFAFJSONResponseSerializer.h"
#import "IFErrorResponseModel.h"
#import "IFDefaultErrorMessage.h"
#import <AFNetworking/AFHTTPSessionManager.h>

static NSString * const kIFNetworkTempDownloadFolder = @"iftemp";
NSString * const IFNetworkResponseErrorDomain = @"com.mrglzh.error.serialization.response";

@interface IFStubRequestManager (){
    IFNetworkConfig *_config;
    AFHTTPSessionManager *_sessionManager;
    
    dispatch_queue_t _processingQueue;
    NSString *_category;
    NSIndexSet *_allStatusCodes;
}

@property (nonatomic, strong) IFAFJSONResponseSerializer *jsonResponseSerializer;
@property (nonatomic, strong) IFRequestCache *requestCache;
@property (nonatomic, strong) dispatch_queue_t mockRequestQueue;

@end
@implementation IFStubRequestManager

- (instancetype)initWithCategory:(NSString *)category {
    self = [super init];
    if (self) {
        _category        = category;
        _requestCache    = [[IFRequestCache alloc] init];
        _config          = [IFNetworkConfigManager configForCategory:category];
        _allStatusCodes  = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 500)];
        _processingQueue = dispatch_queue_create([self queueNameWithCategory:category], DISPATCH_QUEUE_CONCURRENT);
        [self setupSessionManager];
    }
    return self;
}

+ (instancetype)manager {
    return [[self alloc] init];
}

#pragma mark - Private Methods

- (void)setupSessionManager {
    _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:_config.sessionConfiguration];
    _sessionManager.securityPolicy = _config.securityPolicy;
    _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    _sessionManager.responseSerializer.acceptableStatusCodes = _allStatusCodes;
    _sessionManager.completionQueue = _processingQueue;
}

- (const char *)queueNameWithCategory:(NSString *)category {
    return [NSString stringWithFormat:@"com.mrglzh.network.processing.%@", category].UTF8String;
}

- (const char *)mockQueueNameWithCategory:(NSString *)category {
    return [NSString stringWithFormat:@"com.mrglzh.network.apimock.%@", category].UTF8String;
}

- (NSString *)buildRequestURL:(IFBaseRequest *)request {
    NSString *requestURL = [request requestURL];
    NSURL *tempURL = [NSURL URLWithString:requestURL];
    if (tempURL && tempURL.host && tempURL.scheme) {
        return requestURL;
    }
    
    NSString *baseURL = nil;
    if (request.baseURL.length > 0) {
        baseURL = request.baseURL;
    } else if (_config.baseURL){
        baseURL = _config.baseURL();
    }
    
    NSAssert(baseURL.length > 0, @"在没有requestURL不是完整的url的时候，baseURL是必须的");
    NSString *requestURI = request.requestURL;
    if (request.apiVersion.length > 0) {
        requestURI = [request.apiVersion stringByAppendingPathComponent:requestURI];
    }
    
    NSString *url = [baseURL stringByAppendingPathComponent:requestURI];
    if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
        return url;
    } else if ([url hasPrefix:@"http:/"]) {
        url = [url stringByReplacingOccurrencesOfString:@"http:/" withString:@"http://"];
    } else if ([url hasPrefix:@"https:/"]) {
        url = [url stringByReplacingOccurrencesOfString:@"https:/" withString:@"https://"];
    }
    return url;
}

- (void)setHeaders:(NSDictionary *)headers forRequestSerializer:(AFHTTPRequestSerializer *)requestSerializer {
    if (!headers) {
        return;
    }
    for (NSString *headerName in headers.allKeys) {
        [requestSerializer setValue:headers[headerName] forHTTPHeaderField:headerName];
    }
}

- (AFHTTPRequestSerializer *)requestSerializerForRequest:(IFBaseRequest *)request {
    AFHTTPRequestSerializer *requestSerializer = nil;
    NSString *contentType = [request.requestHeaders objectForKey:@"Content-Type"];
    if (!contentType && _config.commonHeaders) {
        contentType = [_config.commonHeaders() objectForKey:@"Content-Type"];
    }
    if (request.httpMethod == IFHTTPRequestMethodPOST && [contentType isEqualToString:@"application/json"]) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    } else {
        if (request.requestSerializerType == IFRequestSerializerTypeJSON) {
            requestSerializer = [AFJSONRequestSerializer serializer];
        } else {
            requestSerializer = [AFHTTPRequestSerializer serializer];
        }
    }
    
    //set timeout
    NSTimeInterval timeoutInterval = 60;
    if (request.timeoutInterval > 0) {
        timeoutInterval = request.timeoutInterval;
    } else if (_config.timeoutInterval > 0) {
        timeoutInterval = _config.timeoutInterval;
    }
    requestSerializer.timeoutInterval = timeoutInterval;
    
    //set user-agent
    NSString *userAgent = [self userAgentForRequest:request];
    if (userAgent) {
        [self setHeaders:@{@"User-Agent": userAgent} forRequestSerializer:requestSerializer];
    }
    
    requestSerializer.allowsCellularAccess = request.allowsCellularAccess;
    
    //设置Headers。
    //1. 设置公用请求头中的信息。
    //2. 然后使用request中的自定义headers进行覆盖操作。
    if (_config.commonHeaders) {
        [self setHeaders:_config.commonHeaders() forRequestSerializer:requestSerializer];
    }
    
    [self setHeaders:request.requestHeaders forRequestSerializer:requestSerializer];
    
    return requestSerializer;
}

- (NSString *)userAgentForRequest:(IFBaseRequest *)request {
    NSString *userAgent = request.userAgent;
    if (userAgent.length <= 0 && _config.userAgent) {
        userAgent = _config.userAgent();
    }
    if (!userAgent) {
        static NSString *commonString = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            UIDevice *device     = [UIDevice currentDevice];
            // FIXME: device 相关参数是否传输
//            NSString *uuid       = [MADevice deviceId];
            NSString *osName     = [device systemName];
            NSString *osVersion  = [device systemVersion];
            NSString *deviceName = [device localizedModel];
            NSString *bundleId   = [[NSBundle mainBundle] bundleIdentifier];
            NSString *buildVer   = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
            NSString *userVer    = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            commonString = [NSString stringWithFormat:@"%@/%@ (%@;%@;%@;%@;",
                            bundleId, userVer, buildVer, osName, osVersion, deviceName];
//            commonString = [NSString stringWithFormat:@"%@/%@ (%@;%@;%@;%@;%@;",
//                            bundleId, userVer, buildVer, uuid, osName, osVersion, deviceName];
        });
        
        NSString *networkType = nil;
        AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
        if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
            networkType = @"wifi";
        } else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
            networkType = @"wwan";
        } else {
            networkType = @"unknow";
        }
        userAgent = [NSString stringWithFormat:@"%@%@)", commonString, networkType];
    }
    return userAgent;
}

- (NSMutableDictionary *)paramsForRequest:(IFBaseRequest *)request {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (_config.commonParams) {
        [params addEntriesFromDictionary:_config.commonParams()];
    }
    if ([request.requestParams count] > 0) {
        [params addEntriesFromDictionary:request.requestParams];
    }
    return params;
}

- (IFRequestSignature *)signatureForRequest:(IFBaseRequest *)request
                                     params:(NSDictionary *)params
                                    headers:(NSDictionary *)headers {
    id<IFRequestSignMethod> signMethod = nil;
    if (request.signMethod) {
        signMethod = request.signMethod;
    } else if (_config.requestSignMethod) {
        signMethod = _config.requestSignMethod;
    }
    
    if ([signMethod respondsToSelector:@selector(sign:headers:)]) {
        return [signMethod sign:params headers:headers];
    }
    return nil;
}

- (Class<IFErrorMessageProtocol>)errorMessageClassForRequest:(IFBaseRequest *)request {
    Class<IFErrorMessageProtocol> errorMessageClass = nil;
    if (request.errorMessageClass) {
        errorMessageClass = request.errorMessageClass;
    } else if (_config.errorMessageClass) {
        errorMessageClass = _config.errorMessageClass;
    } else {
        errorMessageClass = [IFDefaultErrorMessage class];
    }
    return errorMessageClass;
}

- (NSError *)errorForRequest:(IFBaseRequest *)request errCode:(IFErrorCode)errCode errMessage:(NSString *)errMessage {
    NSString *descriptStr = [NSString stringWithFormat:@"%@,%ld",errMessage,request.response.statusCode];
    descriptStr = descriptStr ? descriptStr : @"";
    NSString *requestUrl = request.response.URL.absoluteString ? request.response.URL.absoluteString : @"";
    NSDictionary *userInfo = @{
           NSLocalizedDescriptionKey: descriptStr,
           NSURLErrorFailingURLErrorKey:requestUrl
       };
    return [NSError errorWithDomain:IFNetworkResponseErrorDomain code:errCode userInfo:userInfo];
}

- (IFResponseValidator)responseValidatorForRequest:(IFBaseRequest *)request {
    IFResponseValidator responseValidator = nil;
    if (request.responseValidator) {
        responseValidator = request.responseValidator;
    } else if (_config.responseValidator) {
        responseValidator = _config.responseValidator;
    }
    return responseValidator;
}

- (BOOL)validateResponseForRequest:(IFBaseRequest *)request error:(IFErrorResponseModel * _Nonnull *)errorModel {
    
    BOOL result = YES;
    //校验响应体的格式是否预先规定的格式
    IFResponseValidator responseValidator = [self responseValidatorForRequest:request];
    if (responseValidator) {
        result = responseValidator(request);
    }
    
    if (result) return YES;
    
    if ([request.responseObject isKindOfClass:[IFResponseModel class]]) {
        IFResponseModel *resModel = (IFResponseModel *)request.responseObject;
        IFErrorResponseModel *errorResModel = [IFErrorResponseModel modelWithCode:IFErrorCodeInvalidAPI
                                                                     errorMessage:resModel.message];
        errorResModel.apiCode = resModel.apiCode;
        errorResModel.schema = resModel.schema;
        errorResModel.error = [self errorForRequest:request errCode:IFErrorCodeInvalidAPI errMessage:resModel.message];
        *errorModel = errorResModel;
    } else {
        NSString *errorMessage = [[self errorMessageClassForRequest:request] serverErrorMessage];
        IFErrorResponseModel *errorResModel = [IFErrorResponseModel modelWithCode:IFErrorCodeInvalidAPI
                                                                     errorMessage:errorMessage];
        errorResModel.error = [self errorForRequest:request errCode:IFErrorCodeInvalidAPI errMessage:errorMessage];
        *errorModel = errorResModel;
    }
    return NO;
}

- (id<IFResponseSerialization>)responseSerializationForRequest:(IFBaseRequest *)request {
    if (request.responseSerialization) {
        return request.responseSerialization;
    }
    
    if (_config.responseSerialization) {
        return _config.responseSerialization;
    }
    
    return nil;
}

- (BOOL)validateResponseStatusCode:(IFBaseRequest *)request error:(IFErrorResponseModel * _Nonnull *)errorModel {
    //校验响应码
    if ([request isResponseStatusCodeValid]) {
        return YES;
    }
    NSString *errorMessage = [[self errorMessageClassForRequest:request] serverErrorMessage];
    IFErrorResponseModel *errModel = [IFErrorResponseModel modelWithCode:IFErrorCodeInvalidStatusCode
                                                            errorMessage:errorMessage];
    errModel.error = [self errorForRequest:request errCode:IFErrorCodeInvalidStatusCode errMessage:errorMessage];
    *errorModel = errModel;
    return NO;
}

- (BOOL)serializeResponseForRequest:(IFBaseRequest *)request
                        sessionTask:(NSURLSessionTask *)task
                              error:(IFErrorResponseModel * _Nonnull *)errorModel {
    if (![request.responseData isKindOfClass:[NSData class]]) {
        return YES;
    }
    
    if (request.responseSerializerType != IFResponseSerializerTypeJSON) {
        return YES;
    }
    
    NSError *serializationError = nil;
    id responseJSONObject = [self.jsonResponseSerializer responseObjectForResponse:task.response
                                                                              data:request.responseData
                                                                             error:&serializationError];
    request.responseJSONObject = responseJSONObject;
    request.responseObject     = responseJSONObject;
    request.validData          = responseJSONObject;
    
    if (!serializationError) {
        [_config logMessage:@"===网络请求 [%@] 成功, JSON:\n%@", request, responseJSONObject];
        id<IFResponseSerialization> resSerialization = [self responseSerializationForRequest:request];
        id<IFResponseValidData> responseModel = [resSerialization serialize:request error:&serializationError];
        if (responseModel) {
            request.responseObject = responseModel;
            request.validData = [responseModel validData];
        }
    }
    
    if (serializationError) {
        NSString *errorMessage = [[self errorMessageClassForRequest:request] serverErrorMessage];
        IFErrorResponseModel *errorResModel = [IFErrorResponseModel modelWithCode:IFErrorCodeFailToSerializeResponse
                                                                     errorMessage:errorMessage];
        errorResModel.error = serializationError;
        *errorModel = errorResModel;
    }
    return (serializationError == nil);
}

- (IFErrorResponseModel *)errorResModelForRequest:(IFBaseRequest *)request error:(NSError * _Nonnull)error {
    IFErrorCode errorCode = IFErrorCodeServerError;
    NSString *errorMessage = nil;
    Class<IFErrorMessageProtocol> errorMsgClass = [self errorMessageClassForRequest:request];
    
    if (error.code == NSURLErrorTimedOut) {
        errorCode = IFErrorCodeTimeout;
        errorMessage = [errorMsgClass timeoutMessage];
    } else if (error.code == NSURLErrorNetworkConnectionLost
               || error.code == NSURLErrorNotConnectedToInternet
               || error.code == NSURLErrorCannotLoadFromNetwork) {
        errorCode = IFErrorCodeNetworkNotReachable;
        errorMessage = [errorMsgClass networkErrorMessage];
    } else {
        errorMessage = [errorMsgClass serverErrorMessage];
    }
    IFErrorResponseModel *errorModel = [IFErrorResponseModel modelWithCode:errorCode errorMessage:errorMessage];
    return errorModel;
}

- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error {
    
    IFBaseRequest *request = [_requestCache requestForKey:@(task.taskIdentifier) inCategory:_category];
    if (!request) {
        return;
    }
    
    request.responseObject = responseObject;
    request.validData = responseObject;
    
    BOOL success = NO;
    if ([responseObject isKindOfClass:[NSData class]]) {
        request.responseData   = responseObject;
        request.responseString = [[NSString alloc] initWithData:responseObject
                                                       encoding:[IFNetworkUtil stringEncodingForRequest:request]];
        request.validData = request.responseString;
        
        [_config logMessage:@"===网络请求 [%@] 成功, 原响应串:\n  %@", request, request.responseString];
    }
    
    /**
     * 网络请求结果校验规则：
     * 1. 校验AFN网络请求是否有错误error。
     * 2. 校验网络请求的响应码是否合法。
     * 3. 校验序列化是否成功（JSON和Model序列化）。
     * 4. 校验响应内容是否合法。
     */
    IFErrorResponseModel *errorModel = nil;
    if (error) {
        errorModel = [self errorResModelForRequest:request error:error];
    } else {
        success = (
                   [self validateResponseStatusCode:request error:&errorModel]
                   && [self serializeResponseForRequest:request sessionTask:task error:&errorModel]
                   && [self validateResponseForRequest:request error:&errorModel]
                   );
    }
    
    if (success) {
        [self requestDidSuccess:request];
    } else {
        [self requestDidFailed:request error:errorModel];
    }
    
    if_network_weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        if_network_strongify(self);
        [self.requestCache removeRequest:request];
        [request clearCompletionBlock];
    });
}

- (NSURLSessionDownloadTask *)downloadTaskWithDownloadPath:(NSString *)downloadPath
                                         requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                                 URLString:(NSString *)URLString
                                                parameters:(id)parameters
                                                  progress:(void (^)(NSProgress *downloadProgress))progressBlock
                                                     error:(NSError * _Nullable __autoreleasing *)error {
    // add parameters to URL;
    NSMutableURLRequest *urlRequest = [requestSerializer requestWithMethod:@"GET"
                                                                 URLString:URLString
                                                                parameters:parameters
                                                                     error:error];
    
    NSString *downloadTargetPath;
    BOOL isDirectory;
    if(![[NSFileManager defaultManager] fileExistsAtPath:downloadPath isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    // If targetPath is a directory, use the file name we got from the urlRequest.
    // Make sure downloadTargetPath is always a file, not directory.
    if (isDirectory) {
        NSString *fileName = [urlRequest.URL lastPathComponent];
        downloadTargetPath = [NSString pathWithComponents:@[downloadPath, fileName]];
    } else {
        downloadTargetPath = downloadPath;
    }
    
    // https://github.com/AFNetworking/AFNetworking/issues/3775
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadTargetPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:downloadTargetPath error:nil];
    }
    
    NSURL *tmpDownloadURL = [self tempPathForDownloadPath:downloadPath];
    BOOL resumeDataFileExists = [[NSFileManager defaultManager] fileExistsAtPath:tmpDownloadURL.path];
    NSData *data = [NSData dataWithContentsOfURL:tmpDownloadURL];
    BOOL resumeDataIsValid = [IFNetworkUtil validateResumeData:data];
    
    BOOL canBeResumed = resumeDataFileExists && resumeDataIsValid;
    BOOL resumeSucceeded = NO;
    __block NSURLSessionDownloadTask *downloadTask = nil;
    
    // Try to resume with resumeData.
    // Even though we try to validate the resumeData, this may still fail and raise excecption.
    if (canBeResumed) {
        @try {
            downloadTask = [_sessionManager downloadTaskWithResumeData:data
                                                              progress:progressBlock
                                                           destination:^NSURL *(NSURL *targetPath,
                                                                                NSURLResponse *response) {
                                                               return [NSURL fileURLWithPath:downloadTargetPath
                                                                                 isDirectory:NO];
                                                           } completionHandler:^(NSURLResponse *response,
                                                                                 NSURL *filePath,
                                                                                 NSError *error) {
                                                               [self handleRequestResult:downloadTask
                                                                          responseObject:filePath
                                                                                   error:error];
                                                           }];
            resumeSucceeded = YES;
        } @catch (NSException *exception) {
            [_config logMessage:@"===断点续传失败, 原因: %@", exception.reason];
            resumeSucceeded = NO;
        }
    }
    if (!resumeSucceeded) {
        downloadTask = [_sessionManager downloadTaskWithRequest:urlRequest
                                                       progress:progressBlock
                                                    destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                                        return [NSURL fileURLWithPath:downloadTargetPath
                                                                          isDirectory:NO];
                                                    } completionHandler:^(NSURLResponse *response,
                                                                          NSURL *filePath,
                                                                          NSError *error) {
                                                        [self handleRequestResult:downloadTask
                                                                   responseObject:filePath
                                                                            error:error];
                                                    }];
    }
    return downloadTask;
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                        progress:(void (^)(NSProgress *downloadProgress))progressBlock
                       constructingBodyWithBlock:(nullable IFMultiformDataConstruct)constructBlock
                                           error:(NSError * _Nullable __autoreleasing *)error {
    NSMutableURLRequest *request = nil;
    
    if (constructBlock) {
        request = [requestSerializer multipartFormRequestWithMethod:method
                                                          URLString:URLString
                                                         parameters:parameters
                                          constructingBodyWithBlock:constructBlock
                                                              error:error];
    } else {
        request = [requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:error];
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [_sessionManager dataTaskWithRequest:request
                                     uploadProgress:progressBlock
                                   downloadProgress:NULL
                                  completionHandler:^(NSURLResponse * __unused response,
                                                      id responseObject,
                                                      NSError *_error) {
                                      [self handleRequestResult:dataTask responseObject:responseObject error:_error];
                                  }];
    
    return dataTask;
}

- (NSString *)httpMethodStr:(IFHTTPRequestMethod)httpMethod {
    NSString *httpMethodStr = nil;
    switch (httpMethod) {
        case IFHTTPRequestMethodGET:
            httpMethodStr = @"GET";
            break;
        case IFHTTPRequestMethodPOST:
            httpMethodStr  = @"POST";
            break;
        case IFHTTPRequestMethodPUT:
            httpMethodStr = @"PUT";
            break;
        case IFHTTPRequestMethodHEAD:
            httpMethodStr = @"HEAD";
            break;
        case IFHTTPRequestMethodPATCH:
            httpMethodStr = @"PATCH";
            break;
        case IFHTTPRequestMethodDELETE:
            httpMethodStr = @"DELETE";
            break;
    }
    return httpMethodStr;
}

- (NSURLSessionTask *)sessionTaskForRequest:(IFBaseRequest *)request error:(NSError **)error {
    IFHTTPRequestMethod httpMethod = request.httpMethod;
    NSString *requestURL = [self buildRequestURL:request];
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializerForRequest:request];
    NSMutableDictionary *requestParams = [self paramsForRequest:request];
    
    //对请求参数进行签名算法
    IFRequestSignature *signature = [self signatureForRequest:request
                                                       params:requestParams
                                                      headers:[requestSerializer HTTPRequestHeaders]];
    
    if (signature && signature.signKey && signature.signValue) {
        if (signature.signType == IFRequestSignTypeParam) {
            requestParams[signature.signKey] = signature.signValue;
        } else {
            [requestSerializer setValue:signature.signValue forHTTPHeaderField:signature.signKey];
        }
    }
    
    [_config logMessage:@"===网络请求 [%@], \nurl: %@, \nparams: %@, \nheaders: %@",
                        request, requestURL, requestParams, [requestSerializer HTTPRequestHeaders]];
    
    void(^downloadProgressBlock)(NSProgress *downloadProgress) = nil;
    if (request.progressBlock) {
        downloadProgressBlock = ^(NSProgress *downloadProgress) {
            request.progressBlock(request, downloadProgress);
        };
    }
    
    if (httpMethod == IFHTTPRequestMethodGET && request.resumableDownloadPath) {
        return [self downloadTaskWithDownloadPath:request.resumableDownloadPath
                                requestSerializer:requestSerializer
                                        URLString:requestURL
                                       parameters:requestParams
                                         progress:downloadProgressBlock
                                            error:error];
    }
    
    IFMultiformDataConstruct constructBlock = nil;
    if (httpMethod == IFHTTPRequestMethodPOST) {
        constructBlock = request.multiformConstructor;
    }
    
    NSString *httpMethodStr = [self httpMethodStr:httpMethod];
    if (httpMethodStr) {
        return [self dataTaskWithHTTPMethod:httpMethodStr
                          requestSerializer:requestSerializer
                                  URLString:requestURL
                                 parameters:requestParams
                                   progress:downloadProgressBlock
                  constructingBodyWithBlock:constructBlock
                                      error:error];
    }
    return nil;
}

- (BOOL)responseShouldBeFiltered:(IFBaseRequest *)request {
    NSMutableArray *responseFilters = [[NSMutableArray alloc] init];
    if (request.responseFilter) {
        [responseFilters addObject:request.responseFilter];
    }
    if (_config.responseFilters) {
        [responseFilters addObjectsFromArray:_config.responseFilters];
    }
    
    for (id<IFRequestFilter> filter in responseFilters) {
        if ([filter filter:request]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)shouldExecuteCallbackAfterResponseFilter:(IFBaseRequest *)request {
    BOOL shouldExecute = NO;
    IFCallbackExecutionJudgement judgement = nil;
    
    if (request.judgementAfterResponseFilter) {
        judgement = request.judgementAfterResponseFilter;
    } else if (_config.judgementAfterResponseFilter) {
        judgement = _config.judgementAfterResponseFilter;
    }
    if (judgement) {
        shouldExecute = judgement(request);
    }
    return shouldExecute;
}

- (BOOL)shouldExecuteRequestCallback:(IFBaseRequest *)request {
    if ([self responseShouldBeFiltered:request]) {
        return [self shouldExecuteCallbackAfterResponseFilter:request];
    }
    
    return YES;
}

- (void)requestDidFailed:(IFBaseRequest *)request error:(IFErrorResponseModel *)errorModel {
    
    request.errorModel = errorModel;
    
    [_config logMessage:@"===[%@]失败, StatusCode:%ld, \n%@", request, (long)request.statusCode, errorModel];
    
    //保存未完成的下载数据。
    if (errorModel.error) {
        NSData *incompleteDownloadData = errorModel.error.userInfo[NSURLSessionDownloadTaskResumeData];
        if (incompleteDownloadData) {
            [incompleteDownloadData writeToURL:[self tempPathForDownloadPath:request.resumableDownloadPath]
                                    atomically:YES];
        }
    }

    if_network_weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        if_network_strongify(self);
        [request if_accessoriesWillStop];
        
        if ([self shouldExecuteRequestCallback:request]) {
            if ([request.delegate respondsToSelector:@selector(if_requestFailed:)]) {
                [request.delegate if_requestFailed:request];
            }
            
            if (request.failureBlock) {
                request.failureBlock(request, request.errorModel);
            }
        }
        
        [request if_accessoriesDidStop];
    });
}

- (void)requestDidSuccess:(IFBaseRequest *)request {
    if_network_weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        if_network_strongify(self);
        [request if_accessoriesWillStop];
        
        if ([self shouldExecuteRequestCallback:request]) {
            if ([request.delegate respondsToSelector:@selector(if_requestFinished:)]) {
                [request.delegate if_requestFinished:request];
            }
            
            if (request.successBlock) {
                request.successBlock(request, request.validData);
            }
        }
        
        [request if_accessoriesDidStop];
    });
}

#pragma mark - Resume Downloads

- (NSString *)incompleteDownloadTempCacheFolder {
    
    static NSString *cacheFolder;
    if (!cacheFolder) {
        NSString *cacheDir = NSTemporaryDirectory();
        cacheFolder = [cacheDir stringByAppendingPathComponent:kIFNetworkTempDownloadFolder];
    }
    
    NSError *error = nil;
    if(![[NSFileManager defaultManager] createDirectoryAtPath:cacheFolder
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error]) {
        [_config logMessage:@"===创建缓存目录失败: %@", cacheFolder];
        cacheFolder = nil;
    }
    return cacheFolder;
}

- (NSURL *)tempPathForDownloadPath:(NSString *)downloadPath {
    NSString *tempPath = nil;
    NSString *md5URLString = [IFNetworkUtil md5:downloadPath];
    tempPath = [[self incompleteDownloadTempCacheFolder] stringByAppendingPathComponent:md5URLString];
    return [NSURL fileURLWithPath:tempPath];
}

- (BOOL)validateParamsForRequest:(IFBaseRequest *)request error:(IFErrorResponseModel * _Nonnull *)errorModel {
    NSString *validationMessage = nil;
    BOOL result = [request validateRequestParams:&validationMessage];
    if (result) {
        return YES;
    }
    
    if (!validationMessage) {
        validationMessage = [[self errorMessageClassForRequest:request] requestParamsInvalid];
    }
    *errorModel = [IFErrorResponseModel modelWithCode:IFErrorCodeFailToValidateParams
                                         errorMessage:validationMessage];
    return NO;
}

- (void)if_mockRequest:(IFBaseRequest *)request {
    NSTimeInterval requestTime = 1;
    if ([request respondsToSelector:@selector(mockRequestLoadingTime)]) {
        requestTime = [request mockRequestLoadingTime];
    }
    [_requestCache addRequest:request];
    
    dispatch_async(self.mockRequestQueue, ^{
        [NSThread sleepForTimeInterval:requestTime];
        if ([request respondsToSelector:@selector(mockRequestWithError:)]) {
            IFErrorResponseModel *mockErrorModel = nil;
            request.responseObject = [request mockRequestWithError:&mockErrorModel];
            request.errorModel = mockErrorModel;
        }
        if (request.errorModel) {
            [self requestDidFailed:request error:request.errorModel];
        } else {
            if ([request.responseObject isKindOfClass:[IFResponseModel class]]) {
                request.validData = [(IFResponseModel *)(request.responseObject) validData];
            } else {
                request.validData = request.responseObject;
            }
            [self requestDidSuccess:request];
        }
    });
}

#pragma mark - Public Methods

- (void)addRequest:(IFBaseRequest *)request {
    NSParameterAssert(request != nil);
    request.requestConfig = _config;
    
    [_config logMessage:@"===网络请求开始: [%@]", request];
    
    IFErrorResponseModel *errorModel = nil;
    
    //校验参数的合法性
    if (![self validateParamsForRequest:request error:&errorModel]) {
        [self requestDidFailed:request error:errorModel];
        return;
    }
    
    //判断是否需要模拟数据
    if ([request respondsToSelector:@selector(useMockData)] && [request useMockData]) {
        [self if_mockRequest:request];
        return;
    }
    
    //进行网络请求的sessionTask的封装
    NSError *requestSerializationError = nil;
    request.sessionTask = [self sessionTaskForRequest:request error:&requestSerializationError];
    
    if (requestSerializationError) {
        
        NSString *errorMessage = [[self errorMessageClassForRequest:request] requestParamsInvalid];
        
        errorModel = [IFErrorResponseModel modelWithCode:IFErrorCodeFailToSerializeRequest
                                            errorMessage:errorMessage];
        [self requestDidFailed:request error:errorModel];
        return;
    }
    
    if (request.requestPriority == IFRequestPriorityLow) {
        request.sessionTask.priority = NSURLSessionTaskPriorityLow;
    } else if (request.requestPriority == IFRequestPriorityLow) {
        request.sessionTask.priority = NSURLSessionTaskPriorityHigh;
    } else {
        request.sessionTask.priority = NSURLSessionTaskPriorityDefault;
    }
    [_requestCache addRequest:request];
    [request.sessionTask resume];
}

- (void)cancelRequest:(IFBaseRequest *)request {
    if (request.resumableDownloadPath) {
        NSURLSessionDownloadTask *requestTask = (NSURLSessionDownloadTask *)request.sessionTask;
        [requestTask cancelByProducingResumeData:^(NSData *resumeData) {
            NSURL *localUrl = [self tempPathForDownloadPath:request.resumableDownloadPath];
            [resumeData writeToURL:localUrl atomically:YES];
        }];
    } else {
        [request.sessionTask cancel];
    }
    
    [_requestCache removeRequest:request];
    [request clearCompletionBlock];
}

- (void)cancelAllRequests {
    [_requestCache enumerateAllRequestsUsingBlock:^(IFBaseRequest *request) {
        [request stop];
    }];
}

#pragma mark - Getters and Setters

- (AFJSONResponseSerializer *)jsonResponseSerializer {
    if (!_jsonResponseSerializer) {
        _jsonResponseSerializer = [IFAFJSONResponseSerializer serializer];
        _jsonResponseSerializer.acceptableStatusCodes = _allStatusCodes;
    }
    return _jsonResponseSerializer;
}

- (dispatch_queue_t)mockRequestQueue {
    if (!_mockRequestQueue) {
        const char *mockQueueName = [self mockQueueNameWithCategory:_category];
        _mockRequestQueue = dispatch_queue_create(mockQueueName, DISPATCH_QUEUE_CONCURRENT);
    }
    return _mockRequestQueue;
}


@end
