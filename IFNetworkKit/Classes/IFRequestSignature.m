//
//  IFRequestSignature.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import "IFRequestSignature.h"

@implementation IFRequestSignature

- (instancetype)initWithSignType:(IFRequestSignType)signType
                         signKey:(NSString *)signKey
                       signValue:(NSString *)signValue {
    self = [super init];
    if (self) {
        _signType  = signType;
        _signKey   = signKey;
        _signValue = signValue;
    }
    return self;
}

+ (instancetype)signatureWithType:(IFRequestSignType)signType
                          signKey:(NSString *)signKey
                        signValue:(NSString *)signValue {
    return [[self alloc] initWithSignType:signType
                                  signKey:signKey
                                signValue:signValue];
}

@end
