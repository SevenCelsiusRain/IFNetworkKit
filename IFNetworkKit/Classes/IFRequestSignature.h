//
//  IFRequestSignature.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import <Foundation/Foundation.h>

#ifndef IFRequestSignature_h
#define IFRequestSignature_h

typedef NS_ENUM(NSUInteger, IFRequestSignType) {
    IFRequestSignTypeParam = 0,
    IFRequestSignTypeHeader
};

@interface IFRequestSignature : NSObject

@property (nonatomic, assign, readonly) IFRequestSignType signType;
@property (nonatomic, strong, readonly) NSString *signKey;
@property (nonatomic, strong, readonly) NSString *signValue;

+ (instancetype)signatureWithType:(IFRequestSignType)signType
                          signKey:(NSString *)signKey
                        signValue:(NSString *)signValue;

@end

#endif

