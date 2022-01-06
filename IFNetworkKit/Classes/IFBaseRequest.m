//
//  IFBaseRequest.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import "IFBaseRequest.h"
#import "IFNetworkPrivateUtils.h"
#import "IFNetworkConfig.h"

@interface IFBaseRequest ()

@property (nonatomic, assign, readwrite) IFHTTPRequestMethod httpMethod;
@property (nonatomic, strong, readwrite) NSString * _Nonnull requestURL;

@property (nonatomic, strong, readwrite) NSURLSessionTask *sessionTask;

@property (nonatomic, assign, readwrite) NSInteger statusCode;
@property (nonatomic, strong, readwrite) NSData *responseData;
@property (nonatomic, strong, readwrite) NSString *responseString;
@property (nonatomic, strong, readwrite) id responseJSONObject;
@property (nonatomic, strong, readwrite) id responseObject;

@property (nonatomic, weak) IFNetworkConfig *requestConfig;

@property (nonatomic, strong) id validData;

@end

@implementation IFBaseRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        _httpMethod             = IFHTTPRequestMethodGET;
        _timeoutInterval        = 0;
        _allowsCellularAccess   = YES;
        _resumableDownloadPath  = nil;
        _requestPriority        = IFRequestPriorityDefault;
        _requestSerializerType  = IFRequestSerializerTypeHTTP;
        _responseSerializerType = IFResponseSerializerTypeJSON;
    }
    return self;
}

#pragma mark - Public Methods

- (BOOL)validateRequestParams:(NSString *__autoreleasing *)errorMessage {
    return YES;
}

- (BOOL)inDefaultCategory {
    return [[self requestCategory] isEqualToString:kIFDefaultRequestCategoryName];
}

- (void)clearCompletionBlock {
    self.failureBlock = nil;
    self.successBlock = nil;
}

- (void)start {
    [self if_accessoriesWillStart];
    [[IFRequestManager sharedRequestManager] addRequest:self];
}

- (void)stop {
    [self if_accessoriesWillStop];
    self.delegate = nil;
    [[IFRequestManager sharedRequestManager] cancelRequest:self];
    [self if_accessoriesDidStop];
}

- (void)startWithSuccessBlock:(IFRequestSuccessBlock)successBlock
                 failureBlock:(IFRequestFailBlock)failureBlock {
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    [self start];
}

- (NSURLRequest *)currentRequest {
    return self.sessionTask.currentRequest;
}

- (NSURLRequest *)originRequest {
    return self.sessionTask.originalRequest;
}

- (NSHTTPURLResponse *)response {
    return (NSHTTPURLResponse *)self.sessionTask.response;
}

- (NSInteger)statusCode {
    return self.response.statusCode;
}

- (NSDictionary *)responseHeaders {
    return self.response.allHeaderFields;
}

- (BOOL)isCancelled {
    if (!self.sessionTask) {
        return NO;
    }
    return self.sessionTask.state == NSURLSessionTaskStateCanceling;
}

- (BOOL)isExecuting {
    if (!self.sessionTask) {
        return NO;
    }
    return self.sessionTask.state == NSURLSessionTaskStateRunning;
}

- (BOOL)isResponseStatusCodeValid {
    NSInteger statusCode = self.statusCode;
    return (statusCode >= 200 && statusCode <=299);
}

#pragma mark - Getters and Setters

- (NSString *)requestCategory {
    if (!_requestCategory || _requestCategory.length <= 0) {
        _requestCategory = kIFDefaultRequestCategoryName;
    }
    return _requestCategory;
}

@end
