//
//  NSObject+IFModel.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import <Foundation/Foundation.h>

@interface NSObject (IFModel)

/**
 @see if_modelWithJSON:mapperConfig:keyPropertyMapper:
 
 @param jsonObject 待转换的JSON对象
 @return 当前类的实例或当前类实例的数组
 */
+ (instancetype)if_modelWithJSON:(id)jsonObject;

/**
 将JSON对象转换成当前类对象对应的实例。
 1. 如果JSON对象为数组则转换成当前类对象的数组
 2. 如果JSON对象为字典则转换成当前类对象的实例
 
 @param jsonObject 待转换的JSON对象
 @param mapperConfig 集合类型的配置
 @param keyPropertyMapper 字典中的key和属性名的对应关系
 @return 当前类的实例或当前类实例的数组
 */
+ (instancetype)if_modelWithJSON:(id)jsonObject
                     mapperConfig:(NSDictionary<NSString *, NSString *> *)mapperConfig
                keyPropertyMapper:(NSDictionary<NSString *, NSString *> *)keyPropertyMapper;


/**
 @see if_modelWithArray:mapperConfig:keyPropertyMapper:
 
 @param array 待转换的数组
 @return 当前类实例的数组
 */
+ (NSArray *)if_modelWithArray:(NSArray *)array;

/**
 将字典数组转换成当前类对象的数组
 
 @param array 待转换的数组
 @param mapperConfig 集合类型的配置
 @param keyPropertyMapper 字典中的key和属性名的对应关系
 @return 当前类实例的数组
 */
+ (NSArray *)if_modelWithArray:(NSArray *)array
                   mapperConfig:(NSDictionary<NSString *, NSString *> *)mapperConfig
              keyPropertyMapper:(NSDictionary<NSString *, NSString *> *)keyPropertyMapper;

/**
 @see if_modelWithDictionary:mapperConfig:keyPropertyMapper:
 
 @param dictionary 待转换的字典
 @return 当前类的实例
 */
+ (instancetype)if_modelWithDictionary:(NSDictionary *)dictionary;

/**
 将字典转换成当前类对象的实例。
 
 @param dictionary 待转换的字典
 @param mapperConfig 集合类型的配置
 @param keyPropertyMapper 字典中的key和属性名的对应关系
 @return 当前类的实例
 */
+ (instancetype)if_modelWithDictionary:(NSDictionary *)dictionary
                           mapperConfig:(NSDictionary<NSString *, NSString *> *)mapperConfig
                      keyPropertyMapper:(NSDictionary<NSString *, NSString *> *)keyPropertyMapper;

/**
 配置类中数组元素对应的类名。会覆盖if_jsonKeyCollectionMapper中的配置。
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *if_mapperConfig;

/**
 配置类中的属性应该从json中的哪个key中获取数据值，会覆盖if_jsonKeyPropertyMapper中的配置。
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *if_keyPropertyMapper;

/**
 key: 类中的属性名
 value: NSArray中单个对象对应的类名，如果不配置对应关系则对应的属性直接返回集合对象。
 
 默认的对象映射关系表，如果if_mapperConfig中有重复的key则会替换该配置中的映射关系。
 
 @return 属性名和集合中元素的类名的对应关系。
 */
- (NSDictionary *)if_jsonKeyCollectionMapper;

/**
 key: 在json中的key值
 value: 对应类中的属性名
 
 配置类中的属性应该从json中的哪个key中获取数据值, 如果不配置直接将key作为属性名去获取值.
 默认的对象映射关系表，如果if_keyPropertyMapper中有重复的key则会替换该配置中的映射关系。
 
 @return 属性名和json中key的对应关系
 */
- (NSDictionary *)if_jsonKeyPropertyMapper;

@end

