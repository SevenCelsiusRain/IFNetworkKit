//
//  IFRequestSignMethod.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.

#import <Foundation/Foundation.h>

#ifndef IFRequestSignMethod_h
#define IFRequestSignMethod_h

@class IFRequestSignature;
@protocol IFRequestSignMethod <NSObject>

@required
- (IFRequestSignature *)sign:(NSDictionary *)requestParams headers:(NSDictionary *)requestHeaders;

@end


#endif /* IFRequestSignMethod_h */
