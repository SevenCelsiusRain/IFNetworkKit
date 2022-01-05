//
//  IFDictionaryValueTransformer.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import "IFDictionaryValueTransformer.h"
#import "IFArrayValueTransformer.h"
#import "NSObject+IFModel.h"
#import "IFModelUtil.h"

@implementation IFDictionaryValueTransformer

#pragma mark - IFValueTransformer

- (id)transformValueFromOrigin:(id)originValue {
    
    if (!originValue || ![originValue isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSDictionary *keyCollectionMapping = self.if_mapperConfig;
    
    if ([keyCollectionMapping count] <= 0) {
        return originValue;
    }
    
    return [self dictionaryFromOrigin:originValue
                   keyPropertyMapping:self.if_keyPropertyMapper
                 keyCollectionMapping:keyCollectionMapping];
}

#pragma mark - Private Methods

- (NSDictionary *)dictionaryFromOrigin:(NSDictionary *)originValue
                    keyPropertyMapping:(NSDictionary *)keyPropertyMapping
                  keyCollectionMapping:(NSDictionary *)keyCollectionMapping {
    
    NSMutableDictionary *resultDict  = [NSMutableDictionary dictionary];
    
    [originValue enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        id finalValue = nil;
        
        if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]]) {
            finalValue = [self objectForContainer:obj
                                              key:key
                               keyPropertyMapping:keyPropertyMapping
                             keyCollectionMapping:keyCollectionMapping];
            
        } else {
            finalValue = obj;
        }
        
        if (finalValue) {
            resultDict[key] = finalValue;
        }
    }];
    
    return resultDict;
}

- (id)objectForContainer:(id)dataSource
                     key:(NSString *)key
      keyPropertyMapping:(NSDictionary *)keyPropertyMapping
    keyCollectionMapping:(NSDictionary *)keyCollectionMapping {
    
    Class keyClass = NSClassFromString(keyCollectionMapping[key]);
    
    if (keyClass) {
        return  [self objectForClass:keyClass
                          dataSource:dataSource
                                 key:key
                  keyPropertyMapping:keyCollectionMapping
                keyCollectionMapping:keyPropertyMapping];
    }
    return [self objectForNonClass:dataSource
                               key:key
                keyPropertyMapping:keyCollectionMapping
              keyCollectionMapping:keyPropertyMapping];
    
}

- (id)objectForClass:(Class)targetClass
          dataSource:(id)dataSource
                 key:(NSString *)key
  keyPropertyMapping:(NSDictionary *)keyPropertyMapping
keyCollectionMapping:(NSDictionary *)keyCollectionMapping {
    
    id finalValue = nil;
    
    NSDictionary *config = [IFModelUtil filteredMapping:keyCollectionMapping prefix:key];
    if ([dataSource isKindOfClass:[NSDictionary class]]) {
        
        finalValue = [targetClass if_modelWithDictionary:dataSource
                                            mapperConfig:config
                                       keyPropertyMapper:keyPropertyMapping];
        
    } else if ([dataSource isKindOfClass:[NSArray class]]) {
        
        NSMutableArray *finalArray = [NSMutableArray array];
        [dataSource enumerateObjectsUsingBlock:^(id innerObj, NSUInteger idx, BOOL *stop) {
            
            id arrayItem = nil;
            
            if ([innerObj isKindOfClass:[NSDictionary class]]) {
                
                arrayItem = [targetClass if_modelWithDictionary:innerObj
                                                   mapperConfig:config
                                              keyPropertyMapper:keyPropertyMapping];
                
            } else if ([innerObj isKindOfClass:[NSArray class]]) {
                NSString *className = NSStringFromClass(targetClass);
                IFArrayValueTransformer *arrayVT = [[IFArrayValueTransformer alloc] initWithName:className];
                arrayVT.if_mapperConfig         = config;
                arrayVT.if_keyPropertyMapper    = keyPropertyMapping;
                arrayItem = [arrayVT transformValueFromOrigin:innerObj];
            }
            
            if (arrayItem) {
                [finalArray addObject:arrayItem];
            }
        }];
        finalValue = finalArray;
    }
    
    return finalValue;
}

- (id)objectForNonClass:(id)dataSource
                    key:(NSString *)key
     keyPropertyMapping:(NSDictionary *)keyPropertyMapping
   keyCollectionMapping:(NSDictionary *)keyCollectionMapping {
    
    if ([dataSource isKindOfClass:[NSDictionary class]]) {
        IFDictionaryValueTransformer *dictTransformer = [[IFDictionaryValueTransformer alloc] init];
        dictTransformer.if_mapperConfig = [IFModelUtil filteredMapping:keyCollectionMapping prefix:key];
        return [dictTransformer transformValueFromOrigin:dataSource];
    }
    
    return dataSource;
}


@end
