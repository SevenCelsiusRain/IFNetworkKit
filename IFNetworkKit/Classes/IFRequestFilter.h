//
//  IFRequestFilter.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//
#import <Foundation/Foundation.h>

#ifndef IFRequestFilter_h
#define IFRequestFilter_h

@class IFBaseRequest;
@protocol IFRequestFilter <NSObject>

@required

- (BOOL)filter:(__kindof IFBaseRequest *)request;


#endif /* IFRequestFilter_h */
