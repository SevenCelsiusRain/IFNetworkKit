//
//  IFArrayValueTransformer.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import <Foundation/Foundation.h>
#import "IFValueTransformer.h"

@interface IFArrayValueTransformer : NSObject <IFValueTransformer>

- (instancetype)initWithName:(NSString *)className;
+ (instancetype)valueTransformerWithName:(NSString *)className;

@end
