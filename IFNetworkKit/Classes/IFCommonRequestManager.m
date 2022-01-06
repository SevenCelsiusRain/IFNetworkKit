//
//  IFCommonRequestManager.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/6.
//

#import "IFCommonRequestManager.h"
#import "IFNetworkPrivateUtils.h"

@implementation IFCommonRequestManager

+ (void)requestWithMethod:(IFHTTPRequestMethod)method url:(NSString *)url
               parameters:(NSDictionary<NSString *,id> *)parameters
             SuccessBlock:(IFRequestSuccessBlock)successBlock
             failureBlock:(IFRequestFailBlock)failureBlock {
    [self requestWithMethod:method url:url
                 parameters:parameters
                    headers:nil
                   category:nil
               SuccessBlock:successBlock
               failureBlock:failureBlock];
}

+ (void)requestWithMethod:(IFHTTPRequestMethod)method url:(NSString *)url
               parameters:(NSDictionary<NSString *,id> *)parameters
                  headers:(NSDictionary<NSString *,id> *)headers
                 category:(NSString *)category
             SuccessBlock:(IFRequestSuccessBlock)successBlock
             failureBlock:(IFRequestFailBlock)failureBlock {
    [self requestWithMethod:method url:url
                 parameters:parameters
                    headers:headers
                   category:category
         responseModelClass:nil
             keyClassMapper:nil
          keyPropertyMapper:nil
               SuccessBlock:successBlock
               failureBlock:failureBlock];
}

+ (void)requestWithMethod:(IFHTTPRequestMethod)method url:(NSString *)url
               parameters:(NSDictionary<NSString *,id> *)parameters
                  headers:(NSDictionary<NSString *,id> *)headers
                 category:(NSString *)category
       responseModelClass:(NSString *)responseModelClass
           keyClassMapper:(NSDictionary<NSString *,NSString *> *)keyClassMapper
        keyPropertyMapper:(NSDictionary<NSString *,NSString *> *)keyPropertyMapper
             SuccessBlock:(IFRequestSuccessBlock)successBlock
             failureBlock:(IFRequestFailBlock)failureBlock {
    
    IFBaseRequest *request = [[IFBaseRequest alloc] init];
    Class modelClass = NSClassFromString(responseModelClass);
    if (modelClass) {
        IFModelRequest *modelRequest = [[IFModelRequest alloc] init];
        modelRequest.responseModelClass = responseModelClass;
        modelRequest.keyPropertyMapper = keyPropertyMapper;
        modelRequest.keyClassMapper = keyClassMapper;
        request = modelRequest;
    }
    request.httpMethod = method;
    request.requestURL = url;
    request.requestParams = parameters;
    request.requestHeaders = headers;
    request.requestCategory = category;
    [request startWithSuccessBlock:successBlock failureBlock:failureBlock];
}

@end
