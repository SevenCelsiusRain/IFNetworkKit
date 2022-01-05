//
//  IFArrayValueTransformer.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import "IFArrayValueTransformer.h"
#import "NSObject+IFModel.h"

@interface IFArrayValueTransformer ()
@property (nonatomic, strong) NSString *elementClass;
@end
@implementation IFArrayValueTransformer

- (instancetype)initWithName:(NSString *)className {
    self = [super init];
    if (self) {
        _elementClass = className;
    }
    return self;
}

+ (instancetype)valueTransformerWithName:(NSString *)className {
    return [[self alloc] initWithName:className];
}

- (id)transformValueFromOrigin:(id)originValue {
    
    NSArray *resultArray = nil;
    
    if ([originValue isKindOfClass:[NSArray class]]) {
        
        NSArray *originArray = (NSArray *)originValue;
        
        Class itemClass = NSClassFromString(_elementClass);
        
        if ([originArray count] > 0 && itemClass) {
            
            NSMutableArray *itemArray        = [[NSMutableArray alloc] init];
            NSDictionary *mappingConfig      = self.if_mapperConfig;
            NSDictionary *keyPropertyMapping = self.if_keyPropertyMapper;
            
            for (id innerObject in originArray) {
                if ([innerObject isKindOfClass:[NSDictionary class]]) {
                    [itemArray addObject:[itemClass if_modelWithDictionary:innerObject
                                                              mapperConfig:mappingConfig
                                                         keyPropertyMapper:keyPropertyMapping]];
                } else if ([innerObject isKindOfClass:[NSArray class]]) {
                    IFArrayValueTransformer *arrayVT = [[IFArrayValueTransformer alloc] initWithName:_elementClass];
                    arrayVT.if_mapperConfig          = mappingConfig;
                    arrayVT.if_keyPropertyMapper     = keyPropertyMapping;
                    [self addObjectSafely:[arrayVT transformValueFromOrigin:innerObject]
                                  toArray:itemArray];
                } else {
                    [itemArray addObject:innerObject];
                }
            }
            
            resultArray = itemArray;
        } else {
            resultArray = originArray;
        }
    }
    
    return resultArray;
}

- (void)addObjectSafely:(id)aObject toArray:(NSMutableArray *)array {
    if (aObject) {
        [array addObject:aObject];
    }
}
@end
