//
//  IFModelUtil.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "IFValueTransformer.h"

@interface IFModelUtil : NSObject

+ (Class)classForObjCType:(const char *)ocType;
+ (Class)classFromPropertyAttributes:(const char *)attr;

+ (id)transformValue:(id)originObj
         targetClass:(Class)targetClass
    valueTransformer:(id<IFValueTransformer>)valueTransformer
keyCollectionMapping:(NSDictionary *)keyCollectionMapping
  keyPropertyMapping:(NSDictionary *)keyPropertyMapping
        propertyName:(NSString *)propertyName;

+ (NSDictionary *)filteredMapping:(NSDictionary *)mappingConfig
                           prefix:(NSString *)prefix;

@end

