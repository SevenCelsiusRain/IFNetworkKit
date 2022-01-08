//
//  IFModelSerialization.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/6.
//

#import "IFModelSerialization.h"
#import "IFNetworkPrivateUtils.h"
#import "IFResponseModel.h"
#import "IFModelRequest.h"
#import "IFModel/IFModel.h"

static NSString * const kIFModelSerialErrorDomain = @"com.mrglzh.network.error.serialize";
@implementation IFModelSerialization

#pragma mark - Private Methods

- (id)nonNullObjectFrom:(id)firstObject otherObject:(id)otherObject {
    id result = firstObject;
    if (!result) {
        result = otherObject;
    }
    return result;
}

- (Class)responseModelClass:(IFModelRequest *)modelRequest {
    if (modelRequest.responseModelClass.length > 0) {
        return NSClassFromString(modelRequest.responseModelClass);
    }
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    if (modelRequest.modelClass.length > 0) {
        return NSClassFromString(modelRequest.modelClass);
    }
#pragma clang diagnostic pop
    
    return nil;
}

- (NSInteger)apiCodeFromRequest:(IFModelRequest *)modelRequest jsonObject:(NSDictionary *)jsonObject {
    NSString *codeKey = [self nonNullObjectFrom:modelRequest.codeKey
                                    otherObject:modelRequest.requestConfig.codeKey];
    NSInteger apiCode = NSIntegerMax;
    if (codeKey && jsonObject[codeKey]) {
        apiCode = [jsonObject[codeKey] integerValue];
    }
    return apiCode;
}

- (NSString *)messageFromRequest:(IFModelRequest *)modelRequest jsonObject:(NSDictionary *)jsonObject {
    NSString *message = nil;
    NSString *messageKey = [self nonNullObjectFrom:modelRequest.messageKey
                                       otherObject:modelRequest.requestConfig.messageKey];
    if (messageKey && jsonObject[messageKey]) {
        message = jsonObject[messageKey];
    }
    return message;
}

- (NSString *)schemaFromRequest:(IFModelRequest *)modelRequest jsonObject:(NSDictionary *)jsonObject {
    NSString *schema = nil;
    NSString *schemaKey = [self nonNullObjectFrom:modelRequest.schemaKey
                                      otherObject:modelRequest.requestConfig.schemaKey];
    if (schemaKey && jsonObject[schemaKey]) {
        schema = jsonObject[schemaKey];
    }
    return schema;
}

- (id)dataFromRequest:(IFModelRequest *)modelRequest jsonObject:(NSDictionary *)jsonObject {
    
    NSString *dataKey = [self nonNullObjectFrom:modelRequest.dataKey
                                    otherObject:modelRequest.requestConfig.dataKey];
    id data = nil;
    if (dataKey && jsonObject[dataKey]) {
        data = jsonObject[dataKey];
        Class targetClass = [self responseModelClass:modelRequest];
        if (data && targetClass) {
            data = [targetClass if_modelWithJSON:data
                                    mapperConfig:[modelRequest keyClassMapper]
                               keyPropertyMapper:[modelRequest keyPropertyMapper]];
        }
    }
    
    return data;
}

#pragma mark - Public Methods

- (id)serialize:(__kindof IFBaseRequest *)request error:(NSError *__autoreleasing *)error {
    IFModelRequest *modelRequest = (IFModelRequest *)request;
    id jsonObject = request.responseObject;
    if ([modelRequest isKindOfClass:[IFModelRequest class]] && [jsonObject isKindOfClass:[NSDictionary class]]) {
        
        NSInteger apiCode = [self apiCodeFromRequest:modelRequest jsonObject:jsonObject];
        NSString *message = [self messageFromRequest:modelRequest jsonObject:jsonObject];
        NSString *schema  = [self schemaFromRequest:modelRequest jsonObject:jsonObject];
        id data           = [self dataFromRequest:modelRequest jsonObject:jsonObject];
        return [IFResponseModel modelWithCode:apiCode message:message data:data schema:schema];
    }
    
    if (error) {
        NSString *errorMessage = NSLocalizedString(@"model serialization failure", nil);
        *error = [NSError errorWithDomain:kIFModelSerialErrorDomain
                                     code:1000
                                 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
    }
    return nil;
}

@end
