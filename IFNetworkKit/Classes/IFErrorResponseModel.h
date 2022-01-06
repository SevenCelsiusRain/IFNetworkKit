//
//  IFErrorResponseModel.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import <Foundation/Foundation.h>
#import "IFBaseRequest.h"

typedef NS_ENUM(NSInteger, IFErrorCode) {
    IFErrorCodeNetworkNotReachable = 30000, //网络异常
    IFErrorCodeTimeout,                     //网络超时
    IFErrorCodeInvalidStatusCode,           //非法的响应码
    IFErrorCodeFailToValidateParams,        //请求参数校验失败
    IFErrorCodeInvalidAPI,                  //非法的API
    IFErrorCodeFailToSerializeRequest,      //序列化请求体失败
    IFErrorCodeFailToSerializeResponse,     //序列化响应体失败
    IFErrorCodeServerError                  //服务器错误
};
@interface IFErrorResponseModel : NSObject

@property (nonatomic, assign) IFErrorCode errorCode;
@property (nonatomic, strong) NSString *errorMessage;

@property (nonatomic, assign) NSInteger apiCode;
@property (nonatomic, strong) NSString *schema;
@property (nonatomic, strong) NSError *error;

- (instancetype)initWithCode:(IFErrorCode)errorCode errorMessage:(NSString *)errorMessage;
+ (instancetype)modelWithCode:(IFErrorCode)errorCode errorMessage:(NSString *)errorMessage;

@end

