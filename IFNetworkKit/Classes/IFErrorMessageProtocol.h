//
//  IFErrorMessageProtocol.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//
#import <Foundation/Foundation.h>

#ifndef IFErrorMessageProtocol_h
#define IFErrorMessageProtocol_h

@protocol IFErrorMessageProtocol <NSObject>

@required
+ (NSString *)requestParamsInvalid;
+ (NSString *)timeoutMessage;
+ (NSString *)networkErrorMessage;
+ (NSString *)serverErrorMessage;

@end

#endif /* IFErrorMessageProtocol_h */
