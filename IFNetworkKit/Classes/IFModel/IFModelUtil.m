//
//  IFModelUtil.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import <objc/runtime.h>
#import "IFModelUtil.h"
#import "NSObject+IFModel.h"
#import "IFDictionaryValueTransformer.h"
#import "IFArrayValueTransformer.h"

@implementation IFModelUtil

#pragma mark - Private Methods

+ (BOOL)isCollection:(Class)aClass {
    if ([aClass isSubclassOfClass:[NSArray class]] ||
        [aClass isSubclassOfClass:[NSSet class]] ||
        [aClass isSubclassOfClass:[NSOrderedSet class]]) {
        return YES;
    }
    return NO;
}

+ (id)generateCollection:(Class)aClass {
    if ([aClass isSubclassOfClass:[NSArray class]] || [aClass isSubclassOfClass:[NSOrderedSet class]]) {
        return [NSMutableArray array];
    } else if ([aClass isSubclassOfClass:[NSSet class]]) {
        return [NSMutableSet set];
    }
    
    return nil;
}

#pragma mark - Private Methods

+ (Class)classForOCObject:(const char *)ocClass {
    char *openingQuoteLoc = strchr(ocClass, '"');
    if (openingQuoteLoc) {
        char *closingQuoteLoc = strchr(openingQuoteLoc+1, '"');
        if (closingQuoteLoc) {
            size_t classNameStrLen = closingQuoteLoc-openingQuoteLoc;
            char className[classNameStrLen];
            memcpy(className, openingQuoteLoc+1, classNameStrLen-1);
            // Null-terminate the array to stringify
            className[classNameStrLen-1] = '\0';
            return objc_getClass(className);
        }
    }
    // If there is no quoted class type (id), it can be used as-is.
    return nil;
}

+ (id)arrayFromOrigin:(NSArray *)originArray
          targetClass:(Class)targetClass
     elementClassName:(NSString *)elementClassName
        mappingConfig:(NSDictionary *)mappingConfig
   keyPropertyMapping:(NSDictionary *)keyPropertyMapping {
    
    id finalCollection = [self generateCollection:targetClass];
    Class elementClass = NSClassFromString(elementClassName);
    
    [originArray enumerateObjectsUsingBlock:^(id innerObj, NSUInteger idx, BOOL *innerStop) {
        if ([innerObj isKindOfClass:[NSDictionary class]]) {
            if (elementClass) {
                [finalCollection addObject:[elementClass if_modelWithDictionary:innerObj
                                                                   mapperConfig:mappingConfig
                                                              keyPropertyMapper:keyPropertyMapping]];
            } else {
                IFDictionaryValueTransformer *dictTransformer = [[IFDictionaryValueTransformer alloc] init];
                dictTransformer.if_keyPropertyMapper = keyPropertyMapping;
                dictTransformer.if_mapperConfig = mappingConfig;
                
                id parsedObj = [dictTransformer transformValueFromOrigin:innerObj];
                if (parsedObj) {
                    [finalCollection addObject:parsedObj];
                }
            }
        } else if ([innerObj isKindOfClass:[NSArray class]]) {
            if (elementClass) {
                IFArrayValueTransformer *arrayVT = [[IFArrayValueTransformer alloc] initWithName:elementClassName];
                arrayVT.if_mapperConfig         = mappingConfig;
                arrayVT.if_keyPropertyMapper    = keyPropertyMapping;
                id parsedObj = [arrayVT transformValueFromOrigin:innerObj];
                if (parsedObj) {
                    [finalCollection addObject:parsedObj];
                }
            } else {
                [finalCollection addObject:innerObj];
            }
        } else {
            [finalCollection addObject:innerObj];
        }
    }];
    
    return finalCollection;
}

+ (BOOL)isTrueString:(NSString *)stringValue {
    if ([stringValue isEqualToString:@"t"] ||
        [stringValue isEqualToString:@"true"] ||
        [stringValue isEqualToString:@"y"] ||
        [stringValue isEqualToString:@"yes"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isFalseString:(NSString *)stringValue {
    if ([stringValue isEqualToString:@"false"] ||
        [stringValue isEqualToString:@"f"] ||
        [stringValue isEqualToString:@"n"] ||
        [stringValue isEqualToString:@"no"]) {
        return YES;
    }
    return NO;
}

+ (NSNumber *)numberFromObject:(id)originObj {
    if (![originObj isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    if ([self isTrueString:originObj]) {
        return @YES;
    }
    
    if ([self isFalseString:originObj]) {
        return @NO;
    }
    
    if ([originObj respondsToSelector:@selector(doubleValue)]) {
        return [NSNumber numberWithDouble:[originObj doubleValue]];
    }
    
    return nil;
}

+ (id)collectionObjectFromOrigin:(id)originObj
                     targetClass:(Class)targetClass
            keyCollectionMapping:(NSDictionary *)keyCollectionMapping
              keyPropertyMapping:(NSDictionary *)keyPropertyMapping
                    propertyName:(NSString *)propertyName {
    
    if (![originObj isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSDictionary *tmpKeyCollectionMapping = [self filteredMapping:keyCollectionMapping prefix:propertyName];
    
    id finalCollection = [self arrayFromOrigin:originObj
                                   targetClass:targetClass
                              elementClassName:keyCollectionMapping[propertyName]
                                 mappingConfig:tmpKeyCollectionMapping
                            keyPropertyMapping:keyPropertyMapping];
    
    id finalValue = nil;
    if ([targetClass isSubclassOfClass:[NSOrderedSet class]]) {
        finalValue = [NSOrderedSet orderedSetWithArray:finalCollection];
    } else {
        finalValue = finalCollection;
    }
    
    return finalValue;
}

#pragma mark - Public Methods

+ (Class)classForObjCType:(const char *)ocType {
    if (ocType) {
        switch (ocType[0]) {
            case _C_ID:
                return [self classForOCObject:ocType];
                
            case _C_CHR: // char
            case _C_UCHR: // unsigned char
            case _C_SHT: // short
            case _C_USHT: // unsigned short
            case _C_INT: // int
            case _C_UINT: // unsigned int
            case _C_LNG: // long
            case _C_ULNG: // unsigned long
            case _C_LNG_LNG: // long long
            case _C_ULNG_LNG: // unsigned long long
            case _C_FLT: // float
            case _C_DBL: // double
                return [NSNumber class];
                
            case _C_BOOL: // C++ bool or C99 _Bool
                return objc_getClass("NSCFBoolean")
                ?: objc_getClass("__NSCFBoolean")
                ?: [NSNumber class];
                
            case _C_STRUCT_B: // struct
            case _C_BFLD: // bitfield
            case _C_UNION_B: // union
                return [NSValue class];
                
                //            case _C_ARY_B: // c array
                //            case _C_PTR: // pointer
                //            case _C_VOID: // void
                //            case _C_CHARPTR: // char *
                //            case _C_CLASS: // Class
                //            case _C_SEL: // selector
                //            case _C_UNDEF: // unknown type (function pointer, etc)
            default:
                break;
        }
    }
    return nil;
}

+ (Class)classFromPropertyAttributes:(const char *)attr {
    if (attr) {
        const char *typeIdentifierLoc = strchr(attr, 'T');
        if (typeIdentifierLoc) {
            return [self classForObjCType:typeIdentifierLoc+1];
            
        }
    }
    return nil;
}

+ (BOOL)isUnsupportedClass:(Class)targetClass {
    return ([targetClass isSubclassOfClass:[NSValue class]] ||
            [targetClass isSubclassOfClass:[UIImage class]] ||
            [targetClass isSubclassOfClass:[NSData class]]);
}

+ (id)dictionaryFromValue:(id)originObj
     keyCollectionMapping:(NSDictionary *)keyCollectionMapping
             propertyName:(NSString *)propertyName {
    if (![originObj isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    IFDictionaryValueTransformer *dictTransformer = [[IFDictionaryValueTransformer alloc] init];
    dictTransformer.if_mapperConfig = [self filteredMapping:keyCollectionMapping prefix:propertyName];
    return [dictTransformer transformValueFromOrigin:originObj];
}

+ (NSDate *)dateFromValue:(id)originObj {
    if ([originObj isKindOfClass:[NSString class]] || [originObj respondsToSelector:@selector(doubleValue)]) {
        return [NSDate dateWithTimeIntervalSince1970:[originObj doubleValue]];
    }
    return nil;
}

+ (id)transformValue:(id)originObj
         targetClass:(Class)targetClass
    valueTransformer:(id<IFValueTransformer>)valueTransformer
keyCollectionMapping:(NSDictionary *)keyCollectionMapping
  keyPropertyMapping:(NSDictionary *)keyPropertyMapping
        propertyName:(NSString *)propertyName {
    
    if (!targetClass || !originObj || [originObj isEqual:[NSNull null]]) return nil;
    
    //自定义解析格式
    if (valueTransformer) {
        return [valueTransformer transformValueFromOrigin:originObj];
    }
    
    //集合类型
    if ([self isCollection:targetClass]) {
        return [self collectionObjectFromOrigin:originObj
                                    targetClass:targetClass
                           keyCollectionMapping:keyCollectionMapping
                             keyPropertyMapping:keyPropertyMapping
                                   propertyName:propertyName];
    }
    
    //NSDictionary
    if ([targetClass isSubclassOfClass:[NSDictionary class]]) {
        return [self dictionaryFromValue:originObj
                    keyCollectionMapping:keyCollectionMapping
                            propertyName:propertyName];
    }
    
    //源类型和目前类类型一致直接返回
    if ([originObj isKindOfClass:targetClass]) {
        return originObj;
    }
    
    //NSNumber
    if ([targetClass isSubclassOfClass:[NSNumber class]]) {
        return [self numberFromObject:originObj];
    }
    
    //NSDate
    if ([targetClass isSubclassOfClass:[NSDate class]]) {
        [self dateFromValue:originObj];
    }
    
    //NSURL
    if ([targetClass isSubclassOfClass:[NSURL class]]) {
        if ([originObj isKindOfClass:[NSString class]]) {
            return [NSURL URLWithString:originObj];
        }
        
        return nil;
    }
    
    //NSString
    if ([targetClass isSubclassOfClass:[NSString class]]) {
        if ([originObj respondsToSelector:@selector(stringValue)]) {
            return [originObj stringValue];
        }
        return [originObj description];
    }
    
    //NSValue、UIImage、NSData未支持
    if ([self isUnsupportedClass:targetClass]) {
        return nil;
    }
    
    //对象模型处理
    if ([originObj isKindOfClass:[NSDictionary class]]) {
        return [targetClass if_modelWithDictionary:originObj
                                      mapperConfig:keyCollectionMapping
                                 keyPropertyMapper:keyPropertyMapping];
    }
    
    return nil;
}

+ (NSDictionary *)filteredMapping:(NSDictionary *)mappingConfig prefix:(NSString *)prefix {
    
    if ([mappingConfig count] > 0 && prefix.length > 0) {
        
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        NSString *prefixKey = [NSString stringWithFormat:@"%@.", prefix];
        [mappingConfig enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            if ([key hasPrefix:prefixKey]) {
                NSString *nKey = [key stringByReplacingCharactersInRange:[key rangeOfString:prefixKey] withString:@""];
                if (nKey.length > 0) {
                    resultDict[nKey] = obj;
                }
            }
        }];
        
        if ([resultDict count] > 0) {
            return resultDict;
        }
    }
    return nil;
}


@end
