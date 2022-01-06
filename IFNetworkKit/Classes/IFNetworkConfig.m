//
//  IFNetworkConfig.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import "IFNetworkConfig.h"
#import "IFBaseRequest.h"
#import "IFResponseModel.h"
#import <AFNetworking/AFSecurityPolicy.h>

@implementation IFNetworkConfig
- (instancetype)init {
    self = [super init];
    if (self) {
#ifdef DEBUG
        _debugEnabled = YES;
#endif
        _timeoutInterval = 60;
        _codeKey    = @"code";
        _messageKey = @"message";
        _dataKey    = @"data";
        _schemaKey  = @"schema";
        
        _responseValidator = ^BOOL(IFBaseRequest *request) {
            IFResponseModel *responseModel = request.responseObject;
            BOOL result = YES;
            if ([responseModel isKindOfClass:[IFResponseModel class]]) {
                result = (responseModel.apiCode == 0);
            }
            return result;
        };
    }
    return self;
}

+ (instancetype)networkConfig {
    return [[self alloc] init];
}

#pragma mark - Getters and Setters
- (AFSecurityPolicy *)securityPolicy {
    if (!_securityPolicy) {
        _securityPolicy = [[AFSecurityPolicy alloc] init];
        _securityPolicy.allowInvalidCertificates = YES;
        _securityPolicy.validatesDomainName = NO;
    }
    return _securityPolicy;
}

@end
