//
//  NSString+IFModel.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import <Foundation/Foundation.h>

@interface NSString (IFModel)

/**
 如果当前字符串为合法的JSON串，则转换成对应的类实例。
 
 @param modelClass 待转换的类对象
 @param error 如果转换失败，返回错误信息
 @return 对象实例
 */
- (id)if_jsonStringToModel:(Class)modelClass error:(NSError **)error;

@end

