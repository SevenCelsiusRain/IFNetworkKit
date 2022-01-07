//
//  IFRequestManager.m
//  IFNetworkKit
//
//  Created by MrGLZh on 2022/1/5.
//

#import "IFRequestManager.h"
#import "IFBaseRequest.h"
#import "IFStubRequestManager.h"

@interface IFRequestManager (){
    NSMutableDictionary<NSString *, IFStubRequestManager *> *_stubManagers;
}

@end

@implementation IFRequestManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _stubManagers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (instancetype)sharedRequestManager {
    static IFRequestManager *_sharedRequestManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedRequestManager = [[IFRequestManager alloc] init];
    });
    return _sharedRequestManager;
}

#pragma mark - Private Methods

- (IFStubRequestManager *)stubManagerForCategory:(NSString *)category {
    if (!category) {
        return nil;
    }
    
    IFStubRequestManager *stubManager = _stubManagers[category];
    if (!stubManager) {
        stubManager = [[IFStubRequestManager alloc] initWithCategory:category];
        _stubManagers[category] = stubManager;
    }
    
    return stubManager;
}

- (void)addRequest:(IFBaseRequest *)request {
    [[self stubManagerForCategory:request.requestCategory] addRequest:request];
}

- (void)cancelRequest:(IFBaseRequest *)request {
    [[self stubManagerForCategory:request.requestCategory] cancelRequest:request];
}

- (void)cancelAllRequests {
    NSArray *allKeys = [_stubManagers allKeys];
    if ([allKeys count] > 0) {
        NSArray *copiedKeys = [allKeys copy];
        for (NSString *category in copiedKeys) {
            [_stubManagers[category] cancelAllRequests];
        }
    }
}

#pragma mark - Public Methods

+ (void)cancelAllRequests {
    [[self sharedRequestManager] cancelAllRequests];
}

+ (void)cancelAllRequestsInCategory:(NSString *)category {
    [[[self sharedRequestManager] stubManagerForCategory:category] cancelAllRequests];
}


@end
