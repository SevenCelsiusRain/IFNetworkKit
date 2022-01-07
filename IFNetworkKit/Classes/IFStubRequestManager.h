//
//  IFStubRequestManager.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import <Foundation/Foundation.h>

@class IFBaseRequest;
@interface IFStubRequestManager : NSObject

- (instancetype)initWithCategory:(NSString *)category;

- (void)addRequest:(IFBaseRequest *)request;
- (void)cancelRequest:(IFBaseRequest *)request;

- (void)cancelAllRequests;

@end

