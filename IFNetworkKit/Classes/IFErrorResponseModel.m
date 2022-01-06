//
//  IFErrorResponseModel.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import "IFErrorResponseModel.h"

@implementation IFErrorResponseModel
- (instancetype)initWithCode:(IFErrorCode)errorCode errorMessage:(NSString *)errorMessage {
    self = [super init];
    if (self) {
        _errorCode = errorCode;
        _errorMessage = errorMessage;
    }
    return self;
}

+ (instancetype)modelWithCode:(IFErrorCode)errorCode errorMessage:(NSString *)errorMessage {
    return [[self alloc] initWithCode:errorCode errorMessage:errorMessage];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"===Code: %ld, Message: %@, Error: %@", (long)_errorCode, _errorMessage, _error];
}

@end
