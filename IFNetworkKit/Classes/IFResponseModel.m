//
//  IFResponseModel.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import "IFResponseModel.h"

@implementation IFResponseModel

- (instancetype)initWithCode:(NSInteger)apiCode
                     message:(NSString *)message
                        data:(id)data
                      schema:(NSString *)schema {
    self = [super init];
    if (self) {
        _apiCode = apiCode;
        _message = message;
        _schema  = schema;
        _data    = data;
    }
    return self;
}

+ (instancetype)modelWithCode:(NSInteger)apiCode
                      message:(NSString *)message
                         data:(id)data
                       schema:(NSString *)schema {
    return [[self alloc] initWithCode:apiCode message:message data:data schema:schema];
}

- (instancetype)initWithMessage:(NSString *)message {
    return [self initWithCode:NSIntegerMax message:message data:nil schema:nil];
}

+ (instancetype)modelWithMessage:(NSString *)message {
    return [[self alloc] initWithMessage:message];
}

#pragma mark - Public Methods
- (id)validData {
    return self.data;
}

@end
