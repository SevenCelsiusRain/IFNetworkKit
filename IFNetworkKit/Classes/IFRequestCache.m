//
//  IFRequestCache.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/6.
//

#import "IFRequestCache.h"
#import "IFBaseRequest.h"
#import <pthread/pthread.h>

#define IFLock() pthread_mutex_lock(&_lock)
#define IFUnlock() pthread_mutex_unlock(&_lock)

typedef NSMutableDictionary<NSNumber *, IFBaseRequest *> IFCacheValueType;

@interface IFRequestCache () {
    pthread_mutex_t _lock;
    NSMutableDictionary<NSString *, IFCacheValueType *> *_requests;
}

@end

@implementation IFRequestCache

- (instancetype)init {
    self = [super init];
    if (self) {
        pthread_mutex_init(&_lock, NULL);
        _requests = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Private Methods

- (NSMutableDictionary *)requestsInCategory:(NSString *)category {
    
    if (!category) {
        return nil;
    }
    
    NSMutableDictionary *requestsInCategory = _requests[category];
    if (!requestsInCategory) {
        requestsInCategory = [[NSMutableDictionary alloc] init];
        _requests[category] = requestsInCategory;
    }
    return requestsInCategory;
}

#pragma mark - Public Methods

- (IFBaseRequest *)requestForKey:(NSNumber *)cacheKey inCategory:(NSString *)category {
    if (cacheKey) {
        IFLock();
        NSMutableDictionary *requestsInCategory = [self requestsInCategory:category];
        IFBaseRequest *request = requestsInCategory[cacheKey];
        IFUnlock();
        return request;
    }
    return nil;
}

- (void)addRequest:(IFBaseRequest *)request {
    
    if (!request) {
        return;
    }
    IFLock();
    NSMutableDictionary *requestsInCategory = [self requestsInCategory:request.requestCategory];
    requestsInCategory[@(request.sessionTask.taskIdentifier)] = request;
    IFUnlock();
}

- (void)removeRequest:(IFBaseRequest *)request {
    if (!request) {
        return;
    }
    IFLock();
    NSMutableDictionary *requestsInCategory = [self requestsInCategory:request.requestCategory];
    [requestsInCategory removeObjectForKey:@(request.sessionTask.taskIdentifier)];
    IFUnlock();
}

- (void)enumerateRequestsInCategory:(NSString *)category usingBlock:(IFRequestBlock)requestBlock {
    
    if (!requestBlock) {
        return;
    }
    
    IFLock();
    NSMutableDictionary *requestsInCategory = [self requestsInCategory:category];
    NSArray *allKeys = [requestsInCategory allKeys];
    IFUnlock();
    
    if ([allKeys count] > 0) {
        NSArray *copiedKeys = [allKeys copy];
        
        for (NSNumber *key in copiedKeys) {
            IFLock();
            IFBaseRequest *request = requestsInCategory[key];
            IFUnlock();
            requestBlock(request);
        }
    }
}

- (void)enumerateAllRequestsUsingBlock:(IFRequestBlock)requestBlock {
    
    if (!requestBlock) {
        return;
    }
    
    IFLock();
    NSArray *allCategories = [_requests allKeys];
    IFUnlock();
    
    if ([allCategories count] > 0) {
        allCategories = [allCategories copy];
        for (NSString *category in allCategories) {
            [self enumerateRequestsInCategory:category usingBlock:requestBlock];
        }
    }
}

@end
