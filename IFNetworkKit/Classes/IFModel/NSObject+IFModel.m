//
//  NSObject+IFModel.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import <objc/runtime.h>
#import "NSObject+IFModel.h"
#import "IFValueTransformer.h"
#import "IFModelUtil.h"

static const char IFModelKeyMapperConfig = '\0';
static const char IFModelKeyProertyMapper = '\0';

@implementation NSObject (IFModel)

+ (instancetype)if_modelWithJSON:(id)jsonObject {
    return [self if_modelWithJSON:jsonObject
                     mapperConfig:nil
                keyPropertyMapper:nil];
}

+ (instancetype)if_modelWithJSON:(id)jsonObject
                    mapperConfig:(NSDictionary<NSString *,NSString *> *)mapperConfig
               keyPropertyMapper:(NSDictionary<NSString *, NSString *> *)keyPropertyMapper {
    
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        return [self if_modelWithArray:jsonObject
                          mapperConfig:mapperConfig
                     keyPropertyMapper:keyPropertyMapper];
    } else if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        return [self if_modelWithDictionary:jsonObject
                               mapperConfig:mapperConfig
                          keyPropertyMapper:keyPropertyMapper];
    }
    return nil;
}

+ (NSArray *)if_modelWithArray:(NSArray *)array {
    return [self if_modelWithArray:array
                      mapperConfig:nil
                 keyPropertyMapper:nil];
}

+ (NSArray *)if_modelWithArray:(NSArray *)array
                  mapperConfig:(NSDictionary<NSString *,NSString *> *)mapperConfig
             keyPropertyMapper:(NSDictionary<NSString *, NSString *> *)keyPropertyMapper {
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (id aObject in array) {
        if ([aObject isKindOfClass:[NSDictionary class]]) {
            id resultObject = [self if_modelWithDictionary:aObject
                                              mapperConfig:mapperConfig
                                         keyPropertyMapper:keyPropertyMapper];
            if (resultObject) {
                [dataArray addObject:resultObject];
            }
        }
    }
    
    return dataArray;
}

+ (instancetype)if_modelWithDictionary:(NSDictionary *)dictionary {
    return [self if_modelWithDictionary:dictionary
                           mapperConfig:nil
                      keyPropertyMapper:nil];
}

+ (instancetype)if_modelWithDictionary:(NSDictionary *)dictionary
                          mapperConfig:(NSDictionary<NSString *,NSString *> *)mapperConfig
                     keyPropertyMapper:(NSDictionary<NSString *, NSString *> *)keyPropertyMapper {
    
    if (!dictionary) return nil;
    
    id aObject = [[[self class] alloc] init];
    [aObject setIf_mapperConfig:mapperConfig];
    [aObject setIf_keyPropertyMapper:keyPropertyMapper];
    [aObject if_parseWithDictionary:dictionary];
    return aObject;
}

#pragma mark - Private Methods

- (void)if_parseWithDictionary:(NSDictionary *)dictionary {
    
    NSDictionary *allMappingConfig      = [self if_allMappingConfig];
    NSDictionary *allKeyPropertyMapping = [self if_allKeyPropertyMapping];
    __weak __typeof(self) weakSelf      = self;
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if (obj && ![obj isKindOfClass:[NSNull class]]) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            NSString *propertyName = [strongSelf if_mappingPropertyNameForKey:key inMapping:allKeyPropertyMapping];
            if (propertyName.length > 0) {
                objc_property_t aProperty = class_getProperty([strongSelf class], propertyName.UTF8String);
                
                if (aProperty) {
                    NSDictionary *tmpKeyProMapping = [IFModelUtil filteredMapping:allKeyPropertyMapping prefix:key];
                    Class targetClass = [IFModelUtil classFromPropertyAttributes:property_getAttributes(aProperty)];
                    id finalValue = [IFModelUtil transformValue:obj
                                                    targetClass:targetClass
                                               valueTransformer:nil
                                           keyCollectionMapping:allMappingConfig
                                             keyPropertyMapping:tmpKeyProMapping
                                                   propertyName:propertyName];
                    if (finalValue) {
                        [strongSelf setValue:finalValue forKey:propertyName];
                    }
                }
            }
        }
    }];
}

- (NSString *)if_mappingPropertyNameForKey:(NSString *)key inMapping:(NSDictionary *)kpMapping {
    
    NSString *propertyName = nil;
    if (key.length > 0) {
        propertyName = kpMapping[key];
        if (!propertyName && propertyName.length <= 0) {
            propertyName = key;
        }
    }
    
    return propertyName;
}

- (NSDictionary *)if_allKeyPropertyMapping {
    NSMutableDictionary *allConfig   = [[NSMutableDictionary alloc] initWithDictionary:self.if_keyPropertyMapper];
    NSDictionary *keyPropertyMapping = [self if_jsonKeyPropertyMapper];
    
    if ([keyPropertyMapping count] > 0) {
        [allConfig addEntriesFromDictionary:keyPropertyMapping];
    }
    
    if ([allConfig count] > 0) {
        return allConfig;
    }
    
    return nil;
}

- (NSDictionary *)if_allMappingConfig {
    
    NSMutableDictionary *allConfig     = [[NSMutableDictionary alloc] initWithDictionary:self.if_mapperConfig];
    NSDictionary *keyCollectionMapping = [self if_jsonKeyCollectionMapper];
    
    if ([keyCollectionMapping count] > 0) {
        [allConfig addEntriesFromDictionary:keyCollectionMapping];
    }
    
    if ([allConfig count] > 0) {
        return allConfig;
    }
    
    return nil;
}

#pragma mark - Public Methods

- (NSDictionary *)if_jsonKeyCollectionMapper {
    return nil;
}

- (NSDictionary *)if_jsonKeyPropertyMapper {
    return nil;
}

#pragma mark - Getters and Setters

- (void)setIf_mapperConfig:(NSDictionary<NSString *,NSString *> *)if_mapperConfig {
    objc_setAssociatedObject(self, &IFModelKeyMapperConfig, if_mapperConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary<NSString *,NSString *> *)if_mapperConfig {
    return objc_getAssociatedObject(self, &IFModelKeyMapperConfig);
}

- (void)setIf_keyPropertyMapper:(NSDictionary<NSString *,NSString *> *)if_keyPropertyMapper {
    objc_setAssociatedObject(self, &IFModelKeyProertyMapper, if_keyPropertyMapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary<NSString *,NSString *> *)if_keyPropertyMapper {
    return objc_getAssociatedObject(self, &IFModelKeyProertyMapper);
}

@end
