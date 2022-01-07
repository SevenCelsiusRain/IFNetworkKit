//
//  IFRequestCache.h
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/6.
//

#import <Foundation/Foundation.h>

@class IFBaseRequest;

typedef void (^IFRequestBlock)(IFBaseRequest *request);

@interface IFRequestCache : NSObject

- (IFBaseRequest *)requestForKey:(NSNumber *)cacheKey inCategory:(NSString *)category;

- (void)addRequest:(IFBaseRequest *)request;
- (void)removeRequest:(IFBaseRequest *)request;

- (void)enumerateRequestsInCategory:(NSString *)category usingBlock:(IFRequestBlock)requestBlock;
- (void)enumerateAllRequestsUsingBlock:(IFRequestBlock)requestBlock;


@end
