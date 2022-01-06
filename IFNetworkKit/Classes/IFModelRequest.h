//
//  IFModelRequest.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/6.
//

#import "IFBaseRequest.h"

@interface IFModelRequest : IFBaseRequest

/**
 API状态码对应的字段Key。
 */
@property (nonatomic, strong, readonly) NSString *codeKey;

/**
 API信息对应的字段Key。
 */
@property (nonatomic, strong, readonly) NSString *messageKey;

/**
 API路由对应的字段Key。
 */
@property (nonatomic, strong, readonly) NSString *schemaKey;

/**
 API数据段对应的字段Key。
 */
@property (nonatomic, strong, readonly) NSString *dataKey;

/**
 JSON对象中数据段data将要转换成的对象类型。后续会废弃，请使用responseModelClass。
 */
@property (nonatomic, strong, readonly) NSString *modelClass DEPRECATED_ATTRIBUTE;

/**
 JSON对象中数据段data将要转换成的对象类型。
 */
@property (nonatomic, strong, readonly) NSString *responseModelClass;

/**
 JSON对象转换成特定对象，需要的配置项。配置字典中的key对应的对象类型。
 key为带转换的JSON对象字典中的key，支持keyPath。例如user.address。
 value为将转换的对象类型。
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSString *> *keyClassMapper;

/**
 JSON对象转换成特定对象，需要的配置项.自定义字典中的key对应的属性名。
 key为带转换的JSON对象字典中的key。
 value为将转换的属性名字。
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSString *> *keyPropertyMapper;

@end

