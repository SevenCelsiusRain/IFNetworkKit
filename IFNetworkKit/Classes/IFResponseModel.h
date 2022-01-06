//
//  IFResponseModel.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import <Foundation/Foundation.h>
#import "IFBaseRequest.h"

/**
 IFModelRequest的响应体序列化后产生的基础对象。
 */
@interface IFResponseModel : NSObject<IFResponseValidData>
@property (nonatomic, assign) NSInteger apiCode;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *schema;
@property (nonatomic, strong) id data;

- (instancetype)initWithCode:(NSInteger)apiCode message:(NSString *)message data:(id)data schema:(NSString *)schema;
+ (instancetype)modelWithCode:(NSInteger)apiCode message:(NSString *)message data:(id)data schema:(NSString *)schema;

- (instancetype)initWithMessage:(NSString *)message;
+ (instancetype)modelWithMessage:(NSString *)message;

@end
